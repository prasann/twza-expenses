require 'spec_helper'

describe ProfilesController do
  it "should fetch the profile for the given name using like" do
    profile_1 = Profile.new(:common_name => "test", :employee_id => "1")
    profile_2 = Profile.new(:common_name => "test a", :employee_id => "2")
    Profile.should_receive(:where).with("common_name like 'test%'").and_return([profile_1, profile_2])

    get :search_by_name, :term => 'test'

    assigns(:profiles).size.should == 2
    assigns(:profiles).first.should be profile_1
    assigns(:profiles).last.should be profile_2
    response.should be_success
    response.body.should == "[{\"common_name\":\"test\",\"employee_id\":\"1\"},{\"common_name\":\"test a\",\"employee_id\":\"2\"}]"
  end

  it "should fetch the profile for the given id using like" do
    profile_1 = Profile.new(:common_name => "test", :employee_id => "1234")
    profile_2 = Profile.new(:common_name => "test a", :employee_id => "123456")
    Profile.should_receive(:where).with("employee_id like '1234%'").and_return([profile_1, profile_2])

    get :search_by_id, :term => '1234'

    assigns(:profiles).size.should == 2
    assigns(:profiles).first.should be profile_1
    assigns(:profiles).last.should be profile_2
    response.should be_success
    response.body.should == "[{\"common_name\":\"test\",\"employee_id\":\"1234\"},{\"common_name\":\"test a\",\"employee_id\":\"123456\"}]"
  end
end
