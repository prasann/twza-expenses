# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'factory_girl'
FactoryGirl.find_definitions

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.before(:each) do
    ApplicationController.skip_filter :logged_in?
  end

  config.after(:each) do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end

RSpec::Matchers.define :have_same_attributes_as do |expected|
  match do |actual|
    if (actual.is_a? ModelAttributes)
      actual.declared_attributes == expected.declared_attributes
    else
      actual.attributes == expected.attributes
    end
  end
end

# TODO: Fix the type-checking
RSpec::Matchers.define :contain_field do |expected, options = {}|
  # puts "expected: #{expected.inspect}"
  # puts "options: #{options.inspect}"
  match do |actual|
    # puts "actual: #{actual.inspect}"
    # puts "res: #{actual.respond_to?(expected).inspect}"
    # puts "lhs: #{actual.__send__(expected).inspect}"
    # puts "rhs: #{options[:type].inspect}"
    actual.respond_to?(expected) #&& actual.__send__(expected).class == options[:type]
  end
end

