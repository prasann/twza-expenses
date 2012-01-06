require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do

  it "should fetch the profile for the given name using like" do
    profiles = Profile.new
    Profile.should_receive(:where).with("name like 'test%'").and_return(profiles)
    profiles.should_receive(:to_json).and_return({:id => '123', :name => 'test'})
    get :list, :name => 'test'
    assigns(:profiles).should be profiles
    response.should be_success
  end

end
