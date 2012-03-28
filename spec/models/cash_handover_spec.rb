require 'spec_helper'

describe CashHandover do
  describe "validations" do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:conversion_rate) }
    it { should validate_presence_of(:payment_mode) }

    it { should allow_value(CashHandover::CASH).for(:payment_mode) }
    it { should allow_value(CashHandover::CREDIT_CARD).for(:payment_mode) }
  end

  describe "relationships" do
    xit { should belong_to(:expense_settlement) }
  end

  describe "fields" do
    let(:cash_handover) { Factory(:cash_handover) }

    it { should contain_field(:amount, :type => BigDecimal) }
    it { should contain_field(:currency, :type => String) }
    it { should contain_field(:conversion_rate, :type => BigDecimal) }
    it { should contain_field(:payment_mode, :type => String) }
  end

  describe "total_converted_amount" do
    it "should calculate the total converted amount" do
      cash_handover = Factory(:cash_handover, :amount => 123.0, :conversion_rate => 20.0)
      cash_handover.total_converted_amount.to_f.should == 2460.0
    end
  end
end
