require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do

  it "should fetch the profile for the given name using like" do
    profile = Profile.new
    profiles = [profile]
    Profile.should_receive(:where).with("name like 'test%'").and_return(profiles)
    profile.should_receive(:to_special_s).and_return('test - 1')
    get :search_by_name, :term => 'test'
    assigns(:profiles).first.should be profile
    response.should be_success
    response.body.should == "[\"test - 1\"]"
  end

  it "should fetch the profile for the given id using like" do
    profile=Profile.new
    profiles=[profile]
    Profile.should_receive(:where).with("employee_id like '1234%'").and_return(profiles)
    profile.should_receive(:to_special_s).and_return('test - 1234')
    get :search_by_id,:term => '1234'
    assigns(:profiles).first.should be profile
    response.should be_success
    response.body.should == "[\"test - 1234\"]"
  end

end
