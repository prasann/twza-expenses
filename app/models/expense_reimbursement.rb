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
  field :created_by, type: String

  validates_presence_of :expense_report_id, :empl_id, :submitted_on, :total_amount, :status, :created_by, :allow_blank => false
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

    def mark_all_as_complete(reimbursement_ids)
      completed_reimbursements = []
      if(!reimbursement_ids.nil?)
        reimbursements = find(reimbursement_ids)
        completed_reimbursements = reimbursements.collect { |reimbursement|
         reimbursement.__send__(:create_bank_reimbursement, true) }.compact
      end
      completed_reimbursements
    end
  end

  def get_expenses_grouped_by_project_code
    get_expenses.group_by { |expense| expense.project_subproject }
  end

  def get_expenses
    begin
      # REDTAG: If the whole loop is rescued in one fell swoop, then its "all or none" - but is that correct?
      Expense.find(expenses.collect { |expense| expense['expense_id'] })
    rescue Exception => e
      raise "No matching expense found for this settlement. The expense would have been deleted by the user.  "
    end
  end

  def employee_detail
    @employee_detail ||= EmployeeDetail.where(:emp_id => self.empl_id).first
  end

  def close
    self.status = CLOSED
    self.save!
  end

  def is_processed?
    self.status == PROCESSED
  end

  def is_faulty?
    self.status == FAULTY
  end

  def is_closed?
    self.status == CLOSED
  end

  def is_editable?
    !is_processed? && !is_faulty? && !is_closed?
  end

  private
  def create_bank_reimbursement(mark_as_closed)
    if mark_as_closed
      self.close
      EmployeeMailer.non_travel_expense_reimbursement(self).deliver
    end

    bank_detail = BankDetail.for_empl_id(self.empl_id).first
    # TODO: Why are we returning an OStruct rather than an object?
    OpenStruct.new({:empl_id => self.empl_id,
                    :empl_name => bank_detail.try(:empl_name),
                    :bank_account_no => bank_detail.try(:account_no),
                    :cost_in_home_currency => self.total_amount,
                    :deductions => 0.0,
                    :advance => 0.0,
                    :reimbursable_amount => self.total_amount,
                    :expense_report_ids => self.expense_report_id,
                    :created_by => self.created_by,
                    :created_at => self.created_at,
                    :type => 'nontravel_reimbursements',
                    :id => self.id.to_s
                   })
  end
end
