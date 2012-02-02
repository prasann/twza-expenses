require 'ostruct'

class ExpenseReimbursement
  include Mongoid::Document
  include Mongoid::Timestamps

  field :expense_report_id, type: Integer
  field :empl_id, type: String
  field :expenses, type: Array
  field :status, type: String
  field :submitted_on, type: Date
  field :total_amount, type: Float
  field :notes, type: String

  class << self
    def for_empl_id(empl_id)
      where(:empl_id => empl_id)
    end

    def for_expense_report_id(id)
      where(:expense_report_id => id)
    end

    def with_status(status)
      where(:status => status)
    end
  end

  def get_expenses_grouped_by_project_code
    _expenses = get_expenses
    _expenses.group_by { |expense| expense.project + expense.subproject }
  end

  def get_expenses
    Expense.find(expenses.collect { |expense| expense['expense_id'] })
  end

  def self.get_reimbursable_expense_reports(mark_as_closed = false)
    completed_reimbursements = ExpenseReimbursement.with_status('Processed').to_a
    completed_reimbursements.collect { |reimbursement| create_bank_reimbursement(reimbursement, mark_as_closed) }.compact
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

  def close
    self.status = 'Closed'
    self.save
  end

  # TODO: Does this clash with some mongo status of processed?
  def is_processed?
    self.status == 'Processed'
  end

  def is_faulty?
    self.status == 'Faulty'
  end

  private
  def self.create_bank_reimbursement(reimbursement, mark_as_closed)
    bank_detail = BankDetail.for_empl_id(reimbursement.empl_id).first
    reimbursement.close if mark_as_closed

    OpenStruct.new({:empl_id => reimbursement.empl_id,
                    :empl_name => bank_detail.empl_name,
                    :expense_report_ids => reimbursement.expense_report_id,
                    :reimbursable_amount => reimbursement.total_amount,
                    :bank_account_no => bank_detail.account_no
                   })
  end
end
