require 'spec_helper'

describe ExpenseReimbursementsController do
  describe "Get show " do
    it "should show expense reimbursement details" do
      dummy_expense_reimbursement = Factory(:expense_reimbursement)
      expected_expense_reimbursement = Factory(:expense_reimbursement)
      profile = mock('profile')
      expected_expense_reimbursement.should_receive(:profile).and_return(profile)
      profile.should_receive(:get_full_name).and_return('John Smith')
      expected_expenses = mock('expense')
      #expense_reimbursement_2 = mock("expense_reimbursement", :id => 231, :empl_id => 231)

      ExpenseReimbursement.should_receive(:find).with(expected_expense_reimbursement.id.to_s).and_return(expected_expense_reimbursement)

      expected_expense_reimbursement.should_receive(:get_expenses_grouped_by_project_code).and_return(expected_expenses)

      get :show, :id => expected_expense_reimbursement.id.to_s

      assigns(:expense_reimbursement).should == expected_expense_reimbursement
      assigns(:all_expenses).should == expected_expenses
      assigns(:empl_name).should == 'John Smith'
    end
  end

  describe "Get edit " do
    it "should load only expenses which are not processed as part of another expense reimbursement" do
      expense_1 = mock('expense_1', :project => 'project', :subproject => 'subproject', :project_subproject => 'projectsubproject',
                       :cost_in_home_currency => 1000, :get_employee_id => 1234, :report_submitted_at => 'date')
      expense_2 = mock('expense_2', :project => 'project', :subproject => 'subproject', :project_subproject => 'projectsubproject',
                       :cost_in_home_currency => 200, :get_employee_id => 1234, :report_submitted_at => 'date')

      existing_expense_reimbursement = mock("expense_reimbursement", :id => 123,
                                            :empl_id => 1234, :expense_report_id => 12345, :get_expenses => [expense_2])
      profile = mock('profile')
      expected_expenses = {"projectsubproject" => [expense_1]}

      expected_expense_reimbursement = {'expense_report_id' => '123',
                                        'empl_id' => 1234,
                                        'submitted_on' => 'date',
                                        'total_amount' => 1000.0}

      ExpenseReimbursement.stub_chain(:where, :to_a).and_return([existing_expense_reimbursement])
      Expense.stub_chain(:where, :to_a).and_return([expense_1, expense_2])

      expense_1.should_receive(:profile).and_return(profile)
      profile.should_receive(:get_full_name).and_return('John Smith')

      get :edit, :id => 123

      assigns(:expense_reimbursement).should == expected_expense_reimbursement
      assigns(:all_expenses).count == 1
      assigns(:all_expenses).should == expected_expenses
      assigns(:empl_name).should == 'John Smith'
    end

    it "should load all expenses for new expense reimbursement" do
      expense_1 = mock('expense_1', :project => 'project', :subproject => 'subproject', :project_subproject => 'projectsubproject',
                       :cost_in_home_currency => 1000, :get_employee_id => 1234, :report_submitted_at => 'date')
      expense_2 = mock('expense_2', :project => 'project', :subproject => 'subproject', :project_subproject => 'projectsubproject',
                       :cost_in_home_currency => 200, :get_employee_id => 1234, :report_submitted_at => 'date')

      profile = mock('profile')
      expected_expenses = {"projectsubproject" => [expense_1, expense_2]}

      expected_expense_reimbursement = {'expense_report_id' => '123',
                                        'empl_id' => 1234,
                                        'submitted_on' => 'date',
                                        'total_amount' => 1200.0}

      ExpenseReimbursement.stub_chain(:where, :to_a).and_return([])
      Expense.stub_chain(:where, :to_a).and_return([expense_1, expense_2])

      expense_1.should_receive(:profile).and_return(profile)
      profile.should_receive(:get_full_name).and_return('John Smith')

      get :edit, :id => 123

      assigns(:expense_reimbursement).should == expected_expense_reimbursement
      assigns(:all_expenses).count == 1
      assigns(:all_expenses).should == expected_expenses
      assigns(:empl_name).should == 'John Smith'
    end
  end

  describe " index " do

    it "should load all expenses with filter for processed expenses of travel for the fetched reimbursements" do
      #No exisitng expense reimbursements
      ExpenseReimbursement.stub_chain(:where, :to_a).and_return([])

      expense_1 = Factory(:expense, :cost_in_home_currency => 1000, :empl_id => 1234,
                          :expense_rpt_id => 123)
      expense_2 = Factory(:expense, :cost_in_home_currency => 200, :empl_id => 1234,
                          :expense_rpt_id => 123)
      expense_3 = Factory(:expense, :cost_in_home_currency => 100, :empl_id => 1234,
                          :expense_rpt_id => 123)

      ExpenseSettlement.stub_chain(:find_expense_ids_for_empl_id).and_return([expense_3.id.to_s])

      expected_reimbursement = ExpenseReimbursement.new(:expense_report_id => 123,
                                                       :empl_id => 1234,
                                                       :submitted_on => expense_1.report_submitted_at,
                                                       :total_amount => 1200)

      get :index, :expense_rpt_id => 123

      assigns(:expense_reimbursements).should have(1).items
      assigns(:expense_reimbursements).first.total_amount.should == 1200
      assigns(:expense_reimbursements).first.empl_id.should == "1234"
      assigns(:expense_reimbursements).first.expense_report_id.should == 123
      assigns(:expense_reimbursements).first.submitted_on.should == expense_1.report_submitted_at

    end
  end
end
