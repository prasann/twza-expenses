namespace :data_import do
  desc "Imports Expense sheet into DB"
  task :expense_sheet => :environment do
    ExpenseReportImporter.load
  end
end
