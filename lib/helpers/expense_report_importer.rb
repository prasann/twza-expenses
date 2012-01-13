require 'roo'
require 'csv'
require 'mongoid'
require Rails.root.join("app/models/expense")

class ExpenseReportImporter
	def self.load
		all_files = Dir.glob("data/TWIND*.xlsx")
		all_files.each do |excelxfile|
			load_expense excelxfile		
		end	
	end

	def self.load_expense(excelxfile)
		is_written = Excelx.new(excelxfile).to_csv("data/temp_file.csv")
		if is_written
			all_rows = CSV.read("data/temp_file.csv")
			header = all_rows.shift
			
			convert_to_keys header
			expense_creator = create_expense header
			
			all_rows.each do |row|
				expense_creator.call(row)
			end		
			File.delete("data/temp_file.csv")
		end
	end

	def self.create_expense(header)
		convert_to_keys header
		return Proc.new {|row|
				row_obj = Hash.new
				header.each_index do |i|
					row_obj[header[i]] = row[i]
				end
				Expense.create(row_obj)	
			}
	end

	def self.convert_to_keys(arr)
		arr.each do |key|
			key.downcase!
			key.gsub!(" ", "_")
		end
		return arr
	end
end

