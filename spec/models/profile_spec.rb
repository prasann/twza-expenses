require 'spec_helper'

describe 'profile' do

  it "should display name - id" do
    profile = Profile.new(:name => 'test', :employee_id => '1234')
    profile.to_special_s.should == 'test - 1234'
  end
end
