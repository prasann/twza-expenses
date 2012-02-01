source 'http://rubygems.org'

# TODO: Group all these based on rails env usage
gem 'rails', '~>3.1'
gem 'mongoid'
gem 'bson_ext'
gem 'roo'
gem 'kaminari'
gem 'mysql'   # TODO: Move to mysql2
gem 'premailer-rails3'
gem 'to_xls'
gem 'bcrypt-ruby'
gem 'cancan'
gem 'jquery-rails'

# TODO: Uncomment after putting the required line(s) into the Capfile
#group :assets do
#  gem 'sass-rails',   '~> 3.1.5'
#  gem 'coffee-rails', '~> 3.1.1'
#  gem 'uglifier', '>= 1.0.3'
#end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

group :uat, :production do
  gem 'passenger'
end

group :development do
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git', :require => 'rails_development_boost'
  gem 'mailcatcher'
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'simplecov'
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
end
