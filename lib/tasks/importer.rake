require 'forex_data_importer'

namespace :data_import do
  desc "Import forex details"
  task :forex => :environment do
    ForexDataImporter.new.import('/home/shivasubramanian/Forex Details.xls')
  end
end
