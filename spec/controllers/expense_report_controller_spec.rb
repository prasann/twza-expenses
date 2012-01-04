require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExpenseReportController do

  before(:each) do
	  @criteria_mock = mock(Mongoid::Criteria)
  	@expenses = [Expense.new]
  end

  describe "GET 'fetch'" do

    it "fetches expenses from db for emplid" do
      Expense.stub!(:where).with({:empl_id => "EMP1"}).and_return(@criteria_mock)
	    @criteria_mock.should_receive(:to_a).and_return(@expenses)
	    get :fetch, :empl_id => 1
      assigns(:expenses).should == @expenses
      response.should be_success
    end

  end

end
