class Expense
  include Mongoid::Document

  field :empl_id, type: Integer    #TODO: Why is this in a different type than in other models? Also, why the different names?
  field :old_te_id, type: Integer
  field :expense_rpt_id, type: Integer
  field :original_cost, type: BigDecimal
  field :original_currency, type: String
  field :cost_in_home_currency, type: BigDecimal
  field :expense_date, type: Date
  field :report_submitted_at, type: Date
  field :payment_type, type: String
  field :project, type: String
  field :subproject, type: String
  field :vendor, type: String
  field :is_personal, type: String
  field :attendees, type: String
  field :expense_type, type: String
  field :description, type: String
  field :file_name, type: String

  # TODO: report submitted need not be marked as mandatory as it has no functional significance but submitted on in expense reimbursement is derived from this
  #       if submitted on is removed from mandatory list there report submitted at can be removed from here anycase it is harmless as T&E has that date auto anycase
  validates_presence_of :empl_id, :expense_rpt_id, :payment_type, :original_cost, :original_currency, :cost_in_home_currency, :expense_date, :report_submitted_at, :allow_blank => false
  # payment_type is not being validated to be within a certain set of values - as
  # this data is coming from T&E we accept all values but use certain types for filtering

  class << self
    def for_empl_id(empl_id)
      where(:empl_id => empl_id)
    end

    def for_expense_report_id(id)
      where(:expense_rpt_id => id)
    end

    def fetch_for_employee_between_dates(employee_id, date_from, date_to, ids_to_be_excluded)
      reimbursable_expenses_criteria(for_empl_id(employee_id), ids_to_be_excluded).and(:expense_date.gte => date_from).and(:expense_date.lte => date_to).to_a
    end

    # TODO: See if this can be refactored out
    def fetch_for(criteria, ids_to_be_excluded)
      reimbursable_expenses_criteria(criteria, ids_to_be_excluded).to_a
    end

    # TODO: Performance: Move this into the db - expenses might become too huge for an
    # in clause. Maybe adding a flag to expense (but will make creation costlier)
    def fetch_for_grouped_by_report_id(criteria, ids_to_be_excluded)
      fetch_for(criteria, ids_to_be_excluded).group_by(&:expense_rpt_id)
    end

    private
    def reimbursable_expenses_criteria(criteria, ids_to_be_excluded)
      criteria.not_in(_id: ids_to_be_excluded).excludes(payment_type: 'TW Billed by Vendor')
    end
  end

  def project_subproject
    "#{project}#{subproject}"
  end

  def employee_detail
    @employee_detail ||= EmployeeDetail.where(:emp_id => self.empl_id).first
  end
  
end
