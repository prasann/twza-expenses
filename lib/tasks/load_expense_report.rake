
require Rails.root.join('lib/file_helpers/expense_report')

namespace :dataimport do
  task :expense_sheet => :environment do
    ExpenseReport.load
  end
end
