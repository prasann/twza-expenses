require 'spec_helper'

describe 'profile' do

  it "should display name - id" do
    profile = Profile.new(:common_name => 'test', :employee_id => '1234')
    profile.to_special_s.should == 'test-1234'
  end

  it "should be readonly record" do
    profile = Profile.new(:name => "name", :common_name => "common_name", :employee_id=> '123', :title => "developer")
    expect{profile.save!}.should raise_error ActiveRecord::ReadOnlyRecord
  end

end
