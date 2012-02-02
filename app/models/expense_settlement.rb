require 'mongoid'
require 'ostruct'

class ExpenseSettlement
  # TODO: Should not use helper in model
  include ApplicationHelper
  include Mongoid::Document
  include Mongoid::Timestamps

  field :expenses, type: Array
  field :forex_payments, type: Array
  field :empl_id, type: String
  field :emp_name, type: String

  field :cash_handover, type: Float
  field :status, type: String

  belongs_to :outbound_travel

  class << self
    def for_empl_id(empl_id)
      where(:empl_id => empl_id)
    end

    def with_status(status)
      where(:status => status)
    end
  end

  def profile
    @profile ||= Profile.find_by_employee_id(self.empl_id)
  end

  def email_id
    @email_id ||= profile.email_id.blank? ? empl_id.to_s : profile.email_id
  end

  def employee_email
    email_id + ::Rails.application.config.email_domain
  end

  def notify_employee
    populate_instance_data
    EmployeeMailer.expense_settlement(self).deliver
    self.status = 'Notified Employee'
    self.save
  end

  def complete
    self.status = 'Complete'
    self.save
  end

  def closed
    self.status = 'Closed'
    self.save
  end

  def is_generated_draft?
    self.status == 'Generated Draft'
  end

  def is_complete?
    self.status == 'Complete'
  end

  def is_notified_employee?
    self.status == 'Notified Employee'
  end

  def populate_instance_data
    populate_forex_payments
    populate_consolidated_expenses
    @net_payable ||= get_receivable_amount
  end

  def populate_consolidated_expenses
    @consolidated_expenses = []
    if (expenses && !expenses.empty?)
      expenses_detailed = Expense.find(expenses)

      grpd_by_rpt_id = expenses_detailed.group_by { |expense| expense.expense_rpt_id }
      @consolidated_expenses = grpd_by_rpt_id.values.collect do |expenses|
        consolidate_by_currency(expenses.group_by { |expense| expense.original_currency })
      end
    end
    @consolidated_expenses.flatten!
  end

  def consolidate_by_currency(expenses_by_reportid_hash)
    get_conversion_rates_for_currency
    expense_values = expenses_by_reportid_hash.values
    expense_values.collect do |expenses_by_cur|
      con_exp = Hash.new
      con_exp["amount"] = BigDecimal.new("0")
      expenses_by_cur.each do |expense_cur|
        con_exp["report_id"] = expense_cur.expense_rpt_id
        con_exp["currency"] = expense_cur.original_currency
        con_exp["amount"] = con_exp["amount"] + BigDecimal.new(expense_cur.original_cost)
        con_exp["conversion_rate"] = get_conversion_rate_for(expense_cur)
        # TODO: Should not need to round off to 2 decimal places here - only in views
        con_exp["local_currency_amount"] = format_two_decimal_places(con_exp["amount"] * con_exp["conversion_rate"])
      end
      con_exp
    end
  end

  def get_conversion_rates_for_currency
    relevant_forex = get_forex_payments
    @conversion_rates = relevant_forex.group_by(&:currency)
    @conversion_rates.collect do |currency, forexes|
      inr_sum = 0
      original_amount_sum = 0
      forexes.each do |forex|
        inr_sum += forex.inr.to_f
        original_amount_sum += forex.amount
      end
      # TODO: Should not need to round off to 2 decimal places here - only in views
      @conversion_rates[currency] = format_two_decimal_places(inr_sum / original_amount_sum)
    end
    @conversion_rates
  end

  def populate_forex_payments
    @consolidated_forex = (forex_payments && !forex_payments.empty?) ? ForexPayment.find(forex_payments) : []
  end

  def get_conversion_rate
    (@conversion_rates && !@conversion_rates.empty?) ? @conversion_rates.values.first : 0
  end

  def get_conversion_rate_for(expense_currency)
    @conversion_rates[expense_currency.original_currency] || (expense_currency.cost_in_home_currency.to_f / expense_currency.original_cost.to_f)
  end

  def get_receivable_amount
    expense_inr_amount = 0
    @consolidated_expenses.each { |expense| expense_inr_amount += expense["local_currency_amount"] }
    forex_inr_amount = get_forex_payments.sum(&:inr)
    value = forex_inr_amount - (expense_inr_amount + (cash_handover * get_conversion_rate))
    # TODO: Should not need to round off to 2 decimal places here - only in views
    format_two_decimal_places(value)
  end

  def self.get_reimbursable_expense_reports(mark_as_closed = false)
    completed_settlements = ExpenseSettlement.with_status('Complete').to_a
    completed_settlements.collect { |settlement| create_bank_reimbursement(settlement, mark_as_closed) }.compact
  end

  def get_forex_payments
    @consolidated_forex
  end

  def get_consolidated_expenses
    @consolidated_expenses
  end

  def get_unique_report_ids
    @consolidated_expenses.collect { |expense| expense['report_id'] }.uniq
  end

  private
  def self.create_bank_reimbursement(settlement, mark_as_closed)
    settlement.populate_instance_data
    if (settlement.get_receivable_amount < 0)
      settlement.closed if mark_as_closed
      bank_detail = BankDetail.for_empl_id(settlement.empl_id).first
      return OpenStruct.new({:empl_id => settlement.empl_id,
                             :empl_name => bank_detail.empl_name,
                             :expense_report_ids => settlement.get_unique_report_ids.join(","),
                             :reimbursable_amount => settlement.get_receivable_amount.abs,
                             :bank_account_no => bank_detail.account_no
                            })
    end
  end
end
