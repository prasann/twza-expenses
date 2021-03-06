require 'spec_helper'

describe BankDetail do
  describe "validations" do
    it { should validate_presence_of(:empl_id) }
    it { should validate_presence_of(:empl_name) }

    it { should validate_presence_of(:account_no) }
    it "should validate uniqueness of account_no" do
      FactoryGirl.create(:bank_detail)
      should validate_uniqueness_of(:account_no).with_message('is already taken')
    end
  end

  describe "fields" do
    let(:bank_detail) { FactoryGirl.create(:bank_detail) }

    it { should contain_field(:empl_id, :type => String) }
    it { should contain_field(:empl_name, :type => String) }
    it { should contain_field(:account_no, :type => Integer) }
  end

  describe "for_empl_id" do
    it "should find all the records with the specified empl_id" do
      bank_detail_1 = FactoryGirl.create(:bank_detail, :empl_id => 123)
      bank_detail_2 = FactoryGirl.create(:bank_detail, :empl_id => 123)
      bank_detail_3 = FactoryGirl.create(:bank_detail, :empl_id => 1234)

      result = BankDetail.for_empl_id(123)
      result.count.should == 2
      result.should include(bank_detail_1)
      result.should include(bank_detail_2)
      result.should_not include(bank_detail_3)
    end
  end
end
