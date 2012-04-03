# TODO: Is this even used anywhere in this project?
require 'roo'

class ExpenseImporter
  include ExcelDataExtractor

  def load
    Dir.glob("data/TWIND*.xlsx").each { |excelxfile| load_expense(excelxfile) }
  end

  def load_expense(excelxfile)
    file_name = excelxfile.split("/")[1]
    return false if file_exists?(file_name)
    puts "Processing expense file: #{file_name.to_s}"
    at_least_one_successful_record = read_from_excel(excelxfile, 0) do |extractor|
      expense = nil
      begin
        expense = Expense.new(empl_id: get_employee_id(extractor.call("C")),
                  expense_rpt_id: extractor.call("B").to_i,
                  original_cost: to_money(extractor.call("M")),
                  original_currency: extractor.call("N"),
                  cost_in_home_currency: to_money(extractor.call("E")),
                  expense_date: to_date(extractor.call("J")),
                  report_submitted_at: to_date(extractor.call("T")),
                  payment_type: extractor.call("R"),
                  project: extractor.call("I"),
                  vendor: extractor.call("L"),
                  subproject: extractor.call("U"),
                  expense_type: extractor.call("K"),
                  is_personal: extractor.call("S"),
                  attendees: extractor.call("V"),
                  description: extractor.call("Q"))
      rescue Exception => e
        puts "exception during expense create: " + e.message
        puts "could not create expense for employee: " + extractor.call("C").to_s + " report id: " + extractor.call("B").to_s + " expense_date: " + extractor.call("J").to_s
      end
      expense
    end
    UploadedExpense.create(file_name: file_name) if at_least_one_successful_record
  end

  def file_exists?(file_name)
    UploadedExpense.exists?(conditions: {file_name: file_name})
  end

  def to_money(money_str)
    BigDecimal.new(money_str.to_s).round(2) if !money_str.nil?
  end

  def to_date(date_str)
    DateHelper.date_from_str(date_str.to_s)
  end

  def get_employee_id(id_str)
    id_str.nil? ? nil : id_str.gsub('EMP', '').to_i
  end
end
