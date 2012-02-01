namespace :data_import do
  desc "Imports Expense sheet into DB"
  task :expense_sheet => :environment do
    require Rails.root.join('lib/helpers/expense_report_importer')
    ExpenseReportImporter.load
  end
end
