require 'roo'
require 'csv'
require 'mongoid'
require Rails.root.join("app/models/expense")

class ExpenseReport
	def self.load
		all_files = Dir.glob("data/TWIND*.xlsx")
		all_files.each do |excelxfile|
			is_written = Excelx.new(excelxfile).to_csv("data/temp_file.csv")
			if is_written
				all_rows = CSV.read("data/temp_file.csv")
				header = all_rows.shift
				header.each do |key|
					key.downcase!
					key.gsub!(" ", "_")
				end 
				all_rows.each do |row|
					row_obj = Hash.new
					header.each_index do |i|
						row_obj[header[i]] = row[i]
					end
					Expense.create(row_obj)
				end
				File.delete("data/temp_file.csv")
			end
		end	
	end
end

