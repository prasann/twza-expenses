require 'roo'
require 'csv'
require 'mongoid'
require 'helpers/excel_data_extractor'

class ExpenseReportImporter
  include ExcelDataExtractor

  def load
    all_files = Dir.glob("data/TWIND*.xlsx")
    all_files.each do |excelxfile|
      load_expense excelxfile
    end
  end

  def load_expense(excelxfile)
    file_name = excelxfile.split("/")[1]

    return false if file_exists?(file_name)
    uploaded_expenses_count = 0
    read_from_excel(excelxfile, 0) do |extractor|
      expense = Expense.new(empl_id: get_employee_id(extractor.call("C")), 
                            expense_rpt_id: extractor.call("B").to_i,
                            original_cost: to_money(extractor.call("M")), 
                            original_currency: extractor.call("N"),
                            cost_in_home_currency: to_money(extractor.call("E")), 
                            expense_date: to_date(extractor.call("J")),
                            report_submitted_at: to_date(extractor.call("T")), 
                            payment_type: extractor.call("R"),
                            project: extractor.call("I"),
                            expense_type: extractor.call("K"),
                            description: extractor.call("Q"))
      if expense.save
        uploaded_expenses_count += 1
      else
        puts "Error while processing the record:
          Employee Name: #{extractor.call('D')}
          Expense Date: #{extractor.call('J')} 
          with errors: #{expense.errors} "
      end 
    end

    expenses_uploaded = uploaded_expenses_count > 0

    UploadedExpense.create(file_name: file_name) if expenses_uploaded

    return expenses_uploaded
  end

  def file_exists?(file_name)
    !UploadedExpense.where(file_name: file_name).blank?
  end

  def to_money(money_str)
    if !money_str.nil?
      BigDecimal.new(money_str.to_s).round(2)
    end
  end

  def to_date(date_str)
    if !date_str.nil?
      Date.parse(date_str.to_s)
    end
  end

  def get_employee_id(id_str)
    id_str.gsub('EMP', '').to_i
  end
end
