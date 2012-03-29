require 'spec_helper'

describe ForexPayment do
  before(:each) do
    ForexPayment.delete_all
  end

  describe "validations" do
    it { should validate_presence_of(:emp_id) }
    it { should validate_presence_of(:emp_name) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:travel_date) }
    it { should validate_presence_of(:inr) }
    it { should validate_presence_of(:issue_date) }
    it { should validate_presence_of(:vendor_name) }
  end

  describe "fields" do
    let(:forex_payment) { Factory(:forex_payment) }

    it { should contain_field(:issue_date, :type => Date) }
    it { should contain_field(:emp_id, :type => Integer) }
    it { should contain_field(:emp_name, :type => String) }
    it { should contain_field(:amount, :type => BigDecimal) }
    it { should contain_field(:currency, :type => String) }
    it { should contain_field(:travel_date, :type => Date) }
    it { should contain_field(:place, :type => String) }
    it { should contain_field(:project, :type => String) }
    it { should contain_field(:vendor_name, :type => String) }
    it { should contain_field(:card_number, :type => String) }
    it { should contain_field(:expiry_date, :type => Date) }
    it { should contain_field(:office, :type => String) }
    it { should contain_field(:inr, :type => BigDecimal) }
  end

  describe "fetch_for" do
    it 'should be able to fetch forex paid to an employee between dates' do
      forex_1 = Factory(:forex_payment, :emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=12))
      forex_2 = Factory(:forex_payment, :emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=14))
      forex_3 = Factory(:forex_payment, :emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=17))
      forex_4 = Factory(:forex_payment, :emp_id => '122', :travel_date => Date.new(y=2011, m=12, d=14))
      forex_5 = Factory(:forex_payment, :emp_id => '121', :travel_date => Date.new(y=2011, m=12, d=14))

      valid_forex_payments = ForexPayment.fetch_for('123', Date.new(y=2011, m=12, d=13), Date.new(y=2011, m=12, d=17), [])

      valid_forex_payments.count.should == 2
      valid_forex_payments.should include(forex_2)
      valid_forex_payments.should include(forex_3)
    end
  end

  describe "convert_inr" do
    it "should be tested"
  end

  describe "conversion_rate" do
    it "should be tested"
  end

  describe "expiry_date=" do
    it "should be tested"
  end

  describe "get_json_to_populate" do
    it "should populate unique and non nullable data for auto suggestion" do
      outbound_travel_1 = Factory(:forex_payment, :place => 'US', :currency => 'GBP')
      outbound_travel_2 = Factory(:forex_payment, :place => 'US', :vendor_name => 'VFC', :currency => 'USD')

      fields = ForexPayment.get_json_to_populate('place','vendor_name','currency')

      fields.should be_eql ({'place' => ["US"], 'vendor_name' => ['VKC Forex', 'VFC'], 'currency' => ['GBP','USD']})
    end

    it "should strip the values and then keep uniques"

    it "should remove nils from the result"
  end
end
