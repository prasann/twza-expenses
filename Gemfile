source 'http://rubygems.org'

gem 'rails', '~>3.2.0'
gem 'mongoid'
gem 'bson_ext'
gem 'roo'
gem 'kaminari'
gem 'mysql2', '0.3.10'
gem 'premailer-rails3'
gem 'to_xls'
gem 'bcrypt-ruby'
gem 'cancan'
gem 'jquery-rails'

# TODO: Uncomment after putting the required line(s) into the Capfile
#group :assets do
#  gem 'sass-rails',   '~> 3.2.3'
#  gem 'coffee-rails', '~> 3.2.1'
#  gem 'uglifier', '>= 1.0.3'
#end

# Deploy with Capistrano
gem 'capistrano'

group :uat, :production do
  gem 'passenger'
end

group :development do
  gem 'mailcatcher'
  gem 'bullet'#, '~>2.1.0'
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rspec-instafail'
  gem 'simplecov', :require => false

  # TODO: Convert to use the below gems for better code
  # gem 'mocha'
  gem 'shoulda-matchers'
  gem 'factory_girl'
  # gem 'metrical'
  # gem 'churn', '0.0.13' # Secondary dependency from metrical, v0.0.15 brings in git as dependency
end
