class Expense
  include Mongoid::Document

  def self.fetch_for(employee_id, date_from, date_to, ids_to_be_excluded)
    all_expenses = fetch_for(employee_id, ids_to_be_excluded)
    valid_expenses = all_expenses.reject { |expense|
      Date.parse(expense.expense_date) < date_from || Date.parse(expense.expense_date) > date_to
    }
    return valid_expenses
  end

  def self.fetch_for(employee_id, ids_to_be_excluded)
    Expense.where(empl_id: 'EMP' + employee_id.to_s).
        not_in(_id: ids_to_be_excluded).excludes(payment_type: 'TW Billed by Vendor').to_a
  end

  def get_employee_id
    empl_id.gsub('EMP','')
  end

end
