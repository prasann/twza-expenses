require Rails.root.join('lib/file_helpers/expense_report')

task :load_weekly_expense_sheet => :environment do
	ExpenseReport.load
end
