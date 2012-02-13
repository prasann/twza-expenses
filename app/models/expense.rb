class Expense
  include Mongoid::Document

  field :empl_id, type: Integer
  field :expense_rpt_id, type: Integer
  field :original_cost, type: BigDecimal  
  field :original_currency, type: String 
  field :cost_in_home_currency, type: BigDecimal
  field :expense_date, type: Date   #TODO: Convert to type: Date
  field :report_submitted_at, type: Date  #TODO: Convert to type: Date
  field :payment_type, type: String
  field :project, type: String
  field :expense_type, type: String
  field :description, type: String

  # TODO: Should these be uncommented and tested?
  validates_presence_of :empl_id #, :payment_type, :original_cost, :original_currency, :cost_in_home_currency, :expense_date
  # TODO: validate payment_type is within a certain set of values

  class << self
    def reimbursable_expenses_criteria(criteria, ids_to_be_excluded)
      criteria.not_in(_id: ids_to_be_excluded).excludes(payment_type: 'TW Billed by Vendor')
    end

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
  end

  def profile
    @profile ||= Profile.find_by_employee_id(self.empl_id)
  end

  #TODO: keep this method till usages are removed
  def get_employee_id
    empl_id
  end
end
