require 'data_importer/forex_data_importer'
require 'data_importer/travel_data_importer'
require 'data_importer/bank_details_importer'

namespace :data_import do
  desc "Import forex details - Adds onto the existing DB"
  task :forex_addon => :environment do
    ForexDataImporter.new.import('data/Forex Details.xls')
  end

  desc "Cleans and recreates Import forex details"
  task :forex => :environment do
    ForexPayment.delete_all
    ForexDataImporter.new.import('data/Forex Details.xls')
  end

  desc "Import outbound travel details - Adds onto the existing DB"
  task :travel_addon => :environment do
    TravelDataImporter.new.import('data/Inbound-Outbound Travel.xls')
  end

  desc "Cleans and recreates travel details"
  task :travel => :environment do
    OutboundTravel.delete_all
    TravelDataImporter.new.import('data/Inbound-Outbound Travel.xls')
  end

  desc "Cleans and recreates bank details"
  task :bank => :environment do
    BankDetail.delete_all
    BankDetailsImporter.new.import('data/SCB_nos.xlsx')
  end
end
