require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require Rails.root.join("app/models/expense_report")

describe ExpenseReportController do

  before(:each) do
	@criteria_mock = mock(Mongoid::Criteria)
	@expense_reports = [ExpenseReport.new]
  end

  describe "GET 'fetch'" do

    it "fetches expenses from db for emplid" do
      ExpenseReport.stub!(:where).with({:empl_id => "1"}).and_return(@criteria_mock)
	    @criteria_mock.should_receive(:to_a).and_return(@expense_reports)
	    get :list, :empl_id => 1
      assigns(:expense_reports).should == @expense_reports
      response.should be_success
    end

  end

  describe "POST 'notify'" do
    it "should send notification to employee upon expense settlement computation" do
      expense_report_id = '1'
      employee_id = 1
      expense_report = ExpenseReport.stub(:empl_id => employee_id)
      mock_profile = mock(Profile)
      ExpenseReport.should_receive(:find).with(expense_report_id).and_return(expense_report)
      Profile.should_receive(:find_all_by_employee_id).with(employee_id).and_return(mock_profile)
      expense_settlement_page = 'expense_report_settlement'
      request.env['HTTP_REFERER'] = expense_settlement_page
      post :notify, :id => expense_report_id
      response.should redirect_to expense_settlement_page
    end
  end
end
