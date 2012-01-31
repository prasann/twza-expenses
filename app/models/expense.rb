class Expense
  include Mongoid::Document

  def self.fetch_for_employee_between_dates(employee_id, date_from, date_to, ids_to_be_excluded)
    all_expenses = fetch_for(create_employee_id_criteria(employee_id), ids_to_be_excluded)
    valid_expenses = all_expenses.reject { |expense|
      Date.parse(expense.expense_date) < date_from || Date.parse(expense.expense_date) > date_to
    }
    return valid_expenses
  end

  def self.fetch_for(criteria, ids_to_be_excluded)
    criteria.not_in(_id: ids_to_be_excluded).excludes(payment_type: 'TW Billed by Vendor').to_a
  end

  def self.create_employee_id_criteria(employee_id)
  	Expense.where(empl_id: 'EMP' + employee_id.to_s)
  end

  def get_employee_id
    empl_id.gsub('EMP','')
  end
end
