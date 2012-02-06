SimpleCov.start 'rails' do
  add_filter "/coverage/"
  add_filter "/data/"
  add_filter "/doc/"
  add_filter "/lib/tasks/"
  add_filter "/log/"
  add_filter "/public/"
  add_filter "/script/"
  add_filter "/tmp/"

  add_group "Extras", "lib/helpers"
  add_group "Data Importers", "lib/data_importer"
end# if ENV["COVERAGE"]
