class Expense
  include Mongoid::Document

  field :empl_id, type: String
  field :expense_date   #TODO: Convert to type: Date
  field :report_submitted_at  #TODO: Convert to type: Date
  field :payment_type, type: String

  validates_presence_of :empl_id#, :payment_type
  # TODO: validate payment_type is within a certain set of values

  class << self
    def for_employee_id(employee_id)
      where(:empl_id => 'EMP' + employee_id.to_s)
    end

    # TODO: Is this really correct? Same column/field, with 2 different semantics?
    def for_empl_id(empl_id)
      where(:empl_id => empl_id)
    end

    def for_expense_report_id(id)
      where(:expense_rpt_id => id)
    end
  end

  def self.fetch_for_employee_between_dates(employee_id, date_from, date_to, ids_to_be_excluded)
    all_expenses = fetch_for(for_employee_id(employee_id), ids_to_be_excluded)
    # TODO: Performance: Rather than loading from db into memory and then rejecting based on dates, filter in db itself?
    valid_expenses = all_expenses.reject { |expense|
      Date.parse(expense.expense_date) < date_from || Date.parse(expense.expense_date) > date_to
    }
    return valid_expenses
  end

  # TODO: See if this can be refactored out
  def self.fetch_for(criteria, ids_to_be_excluded)
    criteria.not_in(_id: ids_to_be_excluded).excludes(payment_type: 'TW Billed by Vendor').to_a
  end

  def profile
    @profile ||= Profile.find_by_employee_id(self.get_employee_id.to_i)
  end

  def get_employee_id
    empl_id.gsub('EMP', '')
  end
end
