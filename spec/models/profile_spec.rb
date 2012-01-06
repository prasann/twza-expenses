require 'spec_helper'

describe 'profile' do

  it "profile should display only id and name when converted to json" do
    profile = Profile.new(:name => 'test', :employee_id => '1234')
    profile.to_json.should == {:id=>"1234", :name=>"test"}
    profile.as_json.should == {:id=>"1234", :name=>"test"}
  end
end
