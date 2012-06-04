source 'http://rubygems.org'

gem 'rails', '~>3.2.0'
gem 'mongoid'
gem 'bson_ext'
gem 'roo'
gem 'kaminari'
gem 'premailer-rails3'
gem 'to_xls'
gem 'bcrypt-ruby'
gem 'cancan'
gem 'jquery-rails'
gem 'app_constants'
gem 'typhoeus'

group :assets do
  gem 'execjs'
  gem 'therubyracer'
  gem 'uglifier'
end

# Deploy with Capistrano
gem 'capistrano'

group :development do
  gem 'mailcatcher'
  gem 'bullet'
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
  gem 'metrical'
  gem 'churn', '0.0.13' # Secondary dependency from metrical, v0.0.15 brings in git as dependency
end
