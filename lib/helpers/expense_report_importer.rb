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
    puts "Processing expense file: #{file_name.to_s}"
    has_valid_expenses = false
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
                            vendor: extractor.call("L"),
                            subproject: extractor.call("U"),
                            expense_type: extractor.call("K"),
                            is_personal: extractor.call("S"),
                            attendees: extractor.call("V"),
                            description: extractor.call("Q"))
      if !has_valid_expenses && expense.valid?    #TODO See if this double validation can be done differently
        has_valid_expenses = true
      end
      expense
    end
    UploadedExpense.create(file_name: file_name) if has_valid_expenses
  end

  def duration(diff)
    secs  = diff.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days} days and #{hours % 24} hours"
    elsif hours > 0
      "#{hours} hours and #{mins % 60} minutes"
    elsif mins > 0
      "#{mins} minutes and #{secs % 60} seconds"
    elsif secs >= 0
      "#{secs} seconds"
    end
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
    id_str.nil? ? nil : id_str.gsub('EMP', '').to_i
  end
end
