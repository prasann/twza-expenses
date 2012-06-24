require 'spec_helper'

describe ExpenseReimbursement do

  describe "get_expenses_grouped_by_project_code" do
    it "should get expenses by project code" do
      expense_1 = FactoryGirl.create(:expense, project: 'Project', subproject: 'Sub Project 1')
      expense_2 = FactoryGirl.create(:expense, project: 'Project', subproject: 'Sub Project 1')
      expense_3 = FactoryGirl.create(:expense, project: 'Project', subproject: 'Sub Project 2')
      expenses = [
        {'expense_id' => expense_1.id},
        {'expense_id' => expense_2.id},
        {'expense_id' => expense_3.id}
      ]
      expense_reimbursement = FactoryGirl.create(:expense_reimbursement, :expenses => expenses)

      actual = expense_reimbursement.get_expenses_grouped_by_project_code

      actual.size.should == 2
      actual["ProjectSub Project 1"].count.should == 2
      actual["ProjectSub Project 1"].should include(expense_1)
      actual["ProjectSub Project 1"].should include(expense_2)
      actual["ProjectSub Project 2"].count.should == 1
      actual["ProjectSub Project 2"].should include(expense_3)
    end
  end

  describe "get_expenses" do
    it "should get expenses" do
      expense_1 = FactoryGirl.create(:expense)
      expense_2 = FactoryGirl.create(:expense)
      expense_3 = FactoryGirl.create(:expense)
      expenses = [
        {'expense_id' => expense_1.id},
        {'expense_id' => expense_2.id},
        {'expense_id' => expense_3.id}
      ]
      expense_reimbursement = FactoryGirl.create(:expense_reimbursement, :expenses => expenses)

      actual = expense_reimbursement.get_expenses

      actual.count.should == 3
      actual.should include(expense_1)
      actual.should include(expense_2)
      actual.should include(expense_3)
    end
  end

  describe "validations" do
    it { should validate_presence_of(:empl_id) }
    it { should validate_presence_of(:expense_report_id) }
    it { should validate_presence_of(:submitted_on) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_presence_of(:status) }
    it { should allow_value('Processed').for(:status) }
    it { should allow_value('Unprocessed').for(:status) }
    it { should allow_value('Faulty').for(:status) }
    it { should allow_value('Closed').for(:status) }
  end

  describe "fields" do
    let(:expense_reimbursement) { FactoryGirl.create(:expense_reimbursement) }

    it { should contain_field(:empl_id, :type => String) }
    it { should contain_field(:expense_report_id, :type => Integer) }
    it { should contain_field(:expenses, :type => Array) }
    it { should contain_field(:status, :type => String) }
    it { should contain_field(:submitted_on, :type => Date) }
    it { should contain_field(:total_amount, :type => Float) }
    it { should contain_field(:notes, :type => String) }
  end

  describe "is_processed?" do
    it "should return true if status is PROCESSED" do
      expense_reimbursement_faulty = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::FAULTY)
      expense_reimbursement_faulty.is_processed?.should be_false
      expense_reimbursement_processed = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::PROCESSED)
      expense_reimbursement_processed.is_processed?.should be_true
    end
  end

  describe "close" do
    it "should set the status to Close and save the object" do
      expense_reimbursement = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::FAULTY)
      expense_reimbursement.is_closed?.should be_false
      expense_reimbursement.close
      expense_reimbursement.is_closed?.should be_true
    end
  end

  describe "is_faulty?" do
    it "should return true if status is FAULTY" do
      expense_reimbursement_faulty = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::FAULTY)
      expense_reimbursement_faulty.is_faulty?.should be_true
      expense_reimbursement_closed = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::CLOSED)
      expense_reimbursement_closed.is_faulty?.should be_false
    end
  end

  describe "is_closed?" do
    it "should return true if status is CLOSED" do
      expense_reimbursement_faulty = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::FAULTY)
      expense_reimbursement_faulty.is_closed?.should be_false
      expense_reimbursement_closed = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::CLOSED)
      expense_reimbursement_closed.is_closed?.should be_true
    end
  end

  describe "is_editable?" do
    it "should return true if status is NOT CLOSED or FAULTY or PROCESSED" do
      expense_reimbursement = FactoryGirl.create(:expense_reimbursement)
      expense_reimbursement.is_editable?.should be_true
    end

    it "should return false for all other statuses" do
      expense_reimbursement_faulty = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::FAULTY)
      expense_reimbursement_closed = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::CLOSED)
      expense_reimbursement_processed = FactoryGirl.create(:expense_reimbursement,:status => ExpenseReimbursement::PROCESSED)
      expense_reimbursement_faulty.is_editable?.should be_false
      expense_reimbursement_closed.is_editable?.should be_false
      expense_reimbursement_processed.is_editable?.should be_false
    end
  end
end
