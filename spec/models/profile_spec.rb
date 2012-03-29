require 'spec_helper'

describe Profile do
  let(:profile) { Profile.new(:common_name => "test", :employee_id => '1234', :email_id => 'test@xyz.com', :name => 'Mangatha Test') }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:employee_id) }
    it { should validate_presence_of(:email_id) }
    it { should validate_presence_of(:common_name) }
  end

  describe "readonly?" do
    it "should be readonly record" do
      expect{profile.save!}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it "should not be destroyable" do
      expect{profile.destroy}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe "get_full_name" do
    it "should strip the empty space if there is no surname" do
      profile = Profile.new(:name => "vijay")
      profile.get_full_name.should == "Vijay"
    end

    it "should titleize the words" do
      profile = Profile.new(:name => "vijay", :surname => "aravamudhan")
      profile.get_full_name.should == "Vijay Aravamudhan"
    end
  end
end
