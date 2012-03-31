require 'ostruct'

class ExpenseReimbursement
  include Mongoid::Document
  include Mongoid::Timestamps

  FAULTY      = 'Faulty'
  UNPROCESSED = 'Unprocessed'
  CLOSED      = 'Closed'
  PROCESSED   = 'Processed'

  field :expense_report_id, type: Integer
  field :empl_id, type: String    #TODO: Why is this in a different type than in other models? Also, why the different names?
  field :expenses, type: Array
  field :status, type: String, :default => UNPROCESSED
  field :submitted_on, type: Date
  field :total_amount, type: Float
  field :notes, type: String

  validates_presence_of :expense_report_id, :empl_id, :submitted_on, :total_amount, :status, :allow_blank => false
  validates_inclusion_of :status, :in => [PROCESSED, FAULTY, UNPROCESSED, CLOSED]

  class << self
    def find_for_empl_id(empl_id)
      where(:empl_id => empl_id).to_a
    end

    def find_for_expense_report_id(id)
      where(:expense_report_id => id).to_a
    end

    def with_status(status)
      where(:status => status)
    end

    def get_reimbursable_expense_reports(mark_as_closed = false)
      completed_reimbursements = with_status(PROCESSED).to_a
      completed_reimbursements.collect { |reimbursement| reimbursement.__send__(:create_bank_reimbursement, mark_as_closed) }.compact
    end
  end

  def get_expenses_grouped_by_project_code
    get_expenses.group_by { |expense| expense.project_subproject }
  end

  def get_expenses
    Expense.find(expenses.collect { |expense| expense['expense_id'] })
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
    self.status = CLOSED
    # TODO: What happens if the save fails?
    self.save
  end

  # TODO: Does this clash with some mongo status of processed?
  def is_processed?
    self.status == PROCESSED
  end

  def is_faulty?
    self.status == FAULTY
  end

  private
  def create_bank_reimbursement(mark_as_closed)
    self.close if mark_as_closed

    bank_detail = BankDetail.for_empl_id(self.empl_id).first
    # TODO: What if bank_detail is nil?
    # TODO: Why are we returning a non-object?
    OpenStruct.new({:empl_id => self.empl_id,
                    :empl_name => bank_detail.empl_name,
                    :expense_report_ids => self.expense_report_id,
                    :reimbursable_amount => self.total_amount,
                    :bank_account_no => bank_detail.account_no
                   })
  end
end
