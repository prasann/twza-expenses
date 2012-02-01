require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExpenseReimbursementController do
  describe "Get show " do
    it "should show expense reimbursement details" do
      expected_expense_reimbursement = mock("expense_reimbursement", :id => 123, :empl_id => 1234)
      profile = mock('profile')
      expected_expenses = mock('expense')
      #expense_reimbursement_2 = mock("expense_reimbursement", :id => 231, :empl_id => 231)

      ExpenseReimbursement.should_receive(:find).with("123").and_return(expected_expense_reimbursement)

      Profile.should_receive(:find_by_employee_id).with(1234).and_return(profile)
      profile.should_receive(:get_full_name).and_return('John Smith')
      expected_expense_reimbursement.should_receive(:get_expenses_grouped_by_project_code).and_return(expected_expenses)

      get :show, :id => 123
      assigns(:expense_reimbursement).should == expected_expense_reimbursement
      assigns(:all_expenses).should == expected_expenses
      assigns(:empl_name).should == 'John Smith'
    end
  end

  describe "Get edit " do
    it "should load only expenses which are not processed as part of another expense reimbursement" do
      expense_1 = mock('expense', :project=>'project', :subproject => 'subproject',
                       :cost_in_home_currency=>1000, :get_employee_id=>1234, :report_submitted_at => 'date')
      expense_2 = mock('expense', :project=>'project', :subproject => 'subproject',
                       :cost_in_home_currency=>200, :get_employee_id=>1234, :report_submitted_at => 'date')

      existing_expense_reimbursement = mock("expense_reimbursement", :id => 123,
                                            :empl_id => 1234, :expense_report_id => 12345, :get_expenses=>[expense_2])
      profile = mock('profile')
      expected_expenses = {"projectsubproject"=>[expense_1]}

      expected_expense_reimbursement = {'expense_report_id' => '123',
                                        'empl_id' => 1234,
                                        'submitted_on' => 'date',
                                        'total_amount' => 1000.0}

      ExpenseReimbursement.stub_chain(:where, :to_a).and_return([existing_expense_reimbursement])
      Expense.stub_chain(:where, :to_a).and_return([expense_1, expense_2])

      Profile.should_receive(:find_by_employee_id).with(1234).and_return(profile)
      profile.should_receive(:get_full_name).and_return('John Smith')

      get :edit, :id => 123
      assigns(:expense_reimbursement).should == expected_expense_reimbursement
      assigns(:all_expenses).count == 1
      assigns(:all_expenses).should == expected_expenses
      assigns(:empl_name).should == 'John Smith'
    end

    it "should load all expenses for new expense reimbursement" do
      expense_1 = mock('expense', :project=>'project', :subproject => 'subproject',
                       :cost_in_home_currency=>1000, :get_employee_id=>1234, :report_submitted_at => 'date')
      expense_2 = mock('expense', :project=>'project', :subproject => 'subproject',
                       :cost_in_home_currency=>200, :get_employee_id=>1234, :report_submitted_at => 'date')

      profile = mock('profile')
      expected_expenses = {"projectsubproject"=>[expense_1, expense_2]}

      expected_expense_reimbursement = {'expense_report_id' => '123',
                                        'empl_id' => 1234,
                                        'submitted_on' => 'date',
                                        'total_amount' => 1200.0}

      ExpenseReimbursement.stub_chain(:where, :to_a).and_return([])
      Expense.stub_chain(:where, :to_a).and_return([expense_1, expense_2])

      Profile.should_receive(:find_by_employee_id).with(1234).and_return(profile)
      profile.should_receive(:get_full_name).and_return('John Smith')

      get :edit, :id => 123
      assigns(:expense_reimbursement).should == expected_expense_reimbursement
      assigns(:all_expenses).count == 1
      assigns(:all_expenses).should == expected_expenses
      assigns(:empl_name).should == 'John Smith'
    end
  end

end
