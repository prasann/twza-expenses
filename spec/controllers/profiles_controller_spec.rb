require 'spec_helper'

describe ProfilesController do
  before(:each) do
    Profile.any_instance.stub(:readonly?).and_return(false)
    Profile.delete_all
  end

  it "should fetch the profile for the given name using like" do
    profile_1 = Profile.create!(:common_name => "test", :employee_id => "1", :name => "test", :email_id => "a@b.com")
    profile_2 = Profile.create!(:common_name => "b test a", :employee_id => "2", :name => "test", :email_id => "a@b.com")
    profile_3 = Profile.create!(:common_name => "b te st a", :employee_id => "3", :name => "test", :email_id => "a@b.com")

    get :search_by_name, :term => 'test'

    assigns(:profiles).size.should == 2
    assigns(:profiles).collect(&:employee_id).should include("1")
    assigns(:profiles).collect(&:employee_id).should include("2")
    assigns(:profiles).collect(&:employee_id).should_not include("3")
    response.should be_success
    response.body.should == "[{\"common_name\":\"test\",\"employee_id\":\"1\"},{\"common_name\":\"b test a\",\"employee_id\":\"2\"}]"
  end

  it "should fetch the profile for the given id using like" do
    profile_1 = Profile.create!(:common_name => "test", :employee_id => "1234", :name => "test", :email_id => "a@b.com")
    profile_2 = Profile.create!(:common_name => "test a", :employee_id => "123456", :name => "test", :email_id => "a@b.com")
    profile_3 = Profile.create!(:common_name => "a test b", :employee_id => "124356", :name => "test", :email_id => "a@b.com")

    get :search_by_id, :term => '234'

    assigns(:profiles).size.should == 2
    assigns(:profiles).collect(&:employee_id).should include("1234")
    assigns(:profiles).collect(&:employee_id).should include("123456")
    assigns(:profiles).collect(&:employee_id).should_not include("124356")
    response.should be_success
    response.body.should == "[{\"common_name\":\"test\",\"employee_id\":\"1234\"},{\"common_name\":\"test a\",\"employee_id\":\"123456\"}]"
  end
end
