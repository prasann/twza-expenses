
require Rails.root.join('lib/helpers/expense_report')

namespace :data_import do
  desc "Imports Expense sheet into DB"
  task :expense_sheet => :environment do
    ExpenseReport.load
  end
end
