require 'ostruct'

class ExpenseSettlement
  include NumberHelper
  include Mongoid::Document
  include Mongoid::Timestamps
  include ModelAttributes

  NOTIFIED_EMPLOYEE = 'Notified Employee'
  COMPLETE = 'Complete'
  CLOSED = 'Closed'
  GENERATED_DRAFT = 'Generated Draft'

  field :expenses, type: Array
  field :forex_payments, type: Array
  field :empl_id, type: String    #TODO: Why is this in a different type than in other models? Also, why the different names?
  field :emp_name, type: String    #TODO: Why does this have a different name than in other models?

  field :status, type: String

  belongs_to :outbound_travel

  has_many :cash_handovers
  accepts_nested_attributes_for :cash_handovers

  validates_presence_of :empl_id, :outbound_travel_id, :status
  validates_inclusion_of :status, :in => [GENERATED_DRAFT, NOTIFIED_EMPLOYEE, COMPLETE, CLOSED]

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
    @email_id ||= (profile == nil ||  profile.email_id.blank?) ? empl_id.to_s : profile.email_id
  end

  def employee_email
    email_id + ::Rails.application.config.email_domain
  end

  def notify_employee
    populate_instance_data
    EmployeeMailer.expense_settlement(self).deliver
    self.status = NOTIFIED_EMPLOYEE
    # TODO: What happens if the save fails?
    self.save
  end

  def complete
    self.status = COMPLETE
    # TODO: What happens if the save fails?
    self.save
  end

  def close
    self.status = CLOSED
    # TODO: What happens if the save fails?
    self.save
  end

  def is_generated_draft?
    self.status == GENERATED_DRAFT
  end

  def is_complete?
    self.status == COMPLETE
  end

  def is_notified_employee?
    self.status == NOTIFIED_EMPLOYEE
  end

  # TODO: Remove asap
  def populate_instance_data
    populate_forex_payments
    populate_consolidated_expenses
    @net_payable ||= get_receivable_amount
  end

  def populate_consolidated_expenses
    @consolidated_expenses = []
    if (expenses.present? && !expenses.empty?)
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
        con_exp["currency" ] = expense_cur.original_currency
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
    @consolidated_forex = (forex_payments.present? && !forex_payments.empty?) ? ForexPayment.find(forex_payments) : []
  end

  def get_conversion_rate
    (@conversion_rates.present? && !@conversion_rates.empty?) ? @conversion_rates.values.first : 0
  end

  def get_conversion_rate_for(expense_currency)
    @conversion_rates[expense_currency.original_currency] || (expense_currency.cost_in_home_currency.to_f / expense_currency.original_cost.to_f)
  end

  def get_receivable_amount
    expense_inr_amount = 0
    @consolidated_expenses.each { |expense| expense_inr_amount += expense["local_currency_amount"] }
    forex_inr_amount = get_forex_payments.sum(&:inr)
    @cash_handover_total = 0
    @conversion_rates ||= get_conversion_rates_for_currency
    self.cash_handovers.each do |cash_handover|
      if cash_handover.amount.present? && cash_handover.currency.present?
        @cash_handover_total += cash_handover.amount * @conversion_rates[cash_handover.currency]
      end
    end
    value = forex_inr_amount - (expense_inr_amount + @cash_handover_total)
    # TODO: Should not need to round off to 2 decimal places here - only in views
    format_two_decimal_places(value)
  end

  def self.get_reimbursable_expense_reports(mark_as_closed = false)
    completed_settlements = ExpenseSettlement.with_status(COMPLETE).to_a
    completed_settlements.collect { |settlement| settlement.create_bank_reimbursement(mark_as_closed) }.compact
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

  def create_bank_reimbursement(mark_as_closed)
    self.populate_instance_data
    return if self.get_receivable_amount.negative?

    self.close if mark_as_closed

    bank_detail = BankDetail.for_empl_id(self.empl_id).first
    # TODO: What if bank_detail is nil?
    OpenStruct.new({:empl_id => self.empl_id,
                    :empl_name => bank_detail.empl_name,
                    :expense_report_ids => self.get_unique_report_ids.join(","),
                    :reimbursable_amount => self.get_receivable_amount.abs,
                    :bank_account_no => bank_detail.account_no
                   })
  end
end
