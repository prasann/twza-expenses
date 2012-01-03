
require Rails.root.join('lib/file_helpers/expense_report')
#include ExpenseReport

task :load_weekly_expense_sheet => :environment do
	#ENV['RAILS_ENV'] ||= 'development'
	#ENV['RAKE_ENV'] ||= 'development'
	#puts "in loading expenses report: rails env " + ENV['RAILS_ENV'] 
	#puts "in loading expenses report: rake env " + ENV['RAKE_ENV']
	ExpenseReport.load
end
