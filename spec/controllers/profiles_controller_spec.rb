require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do

  it "should fetch the profile for the given name using like" do
    profile = Profile.new
    profiles = [profile]
    Profile.should_receive(:where).with("name like 'test%'").and_return(profiles)
    profile.should_receive(:to_special_s).and_return('test - 1')
    get :list, :term => 'test'
    assigns(:profiles).first.should be profile
    response.should be_success
    response.body.should == "[\"test - 1\"]"
  end

end
