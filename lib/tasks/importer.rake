namespace :data_import do
  desc "Import forex details - Adds onto the existing DB"
  task :forex_addon => :environment do
    ForexDataImporter.new.import('data/Forex Details.xls')
  end

  desc "Cleans and recreates Import forex details"
  task :forex => :environment do
    if ForexPayment.count() == 0
      Rake::Task['data_import:forex_addon'].invoke
    end
  end

  desc "Import outbound travel details - Adds onto the existing DB"
  task :travel_addon => :environment do
    TravelDataImporter.new.import('data/Inbound-Outbound Travel.xls')
  end

  desc "Creates travel details one time"
  task :travel => :environment do
    if OutboundTravel.count() == 0
      Rake::Task['data_import:travel_addon'].invoke
    end
  end

  desc "Creates bank details one time"
  task :bank => :environment do
    if BankDetail.count() == 0
      BankDetailsImporter.new.import('data/SCB_nos.xlsx')
    end
  end

  desc "Creates Employee details"
  task :employee_details => :environment do
    if EmployeeDetail.count() == 0
      EmployeeDetailsImporter.new.import('data/employee_details.xlsx')
    end
  end

  desc "Imports Expense sheet into DB"
  task :expense_sheet => :environment do
    ExpenseImporter.new.load
  end
end
