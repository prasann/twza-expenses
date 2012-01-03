require 'data_importer/forex_data_importer'
require 'travel_data_importer'

namespace :data_import do
  desc "Import forex details"
  task :forex => :environment do
    ForexDataImporter.new.import('data/Forex Details.xls')
  end

  desc "Import outbound travel details"
  task :travel => :environment do
    TravelDataImporter.new.import('')
  end
end
