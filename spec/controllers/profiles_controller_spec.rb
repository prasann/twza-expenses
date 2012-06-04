require 'spec_helper'

describe ProfilesController do
  it "should fetch the profile for the given name using like" do
    emp_detail_1 = EmployeeDetail.create!(:emp_name => "test", :emp_id => "1", :email => 'a@b.com')
    emp_detail_2 = EmployeeDetail.create!(:emp_name => "b test a", :emp_id => "2", :email => 'a@b1.com')
    emp_detail_3 = EmployeeDetail.create!(:emp_name => "b te st a", :emp_id => "3", :email => 'a@b2.com')

    get :search_by_name, :term => 'test'

    response.should be_success
    response.body.should == "[{\"emp_id\":\"1\",\"emp_name\":\"test\"},{\"emp_id\":\"2\",\"emp_name\":\"b test a\"}]"
  end

  it "should fetch the profile for the given id using like" do
    emp_detail_1 = EmployeeDetail.create!(:emp_name => "test", :emp_id => "1234", :email => 'a@b.com')
    emp_detail_2 = EmployeeDetail.create!(:emp_name => "test a", :emp_id => "123456", :email => 'a@b1.com')
    emp_detail_3 = EmployeeDetail.create!(:emp_name => "b te st a", :emp_id => "43212", :email => 'a@b2.com')

    get :search_by_id, :term => '234'

    response.should be_success
    response.body.should == "[{\"emp_id\":\"1234\",\"emp_name\":\"test\"},{\"emp_id\":\"123456\",\"emp_name\":\"test a\"}]"
  end
end
