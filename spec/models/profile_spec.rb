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

    xit "should not be destroyable" do
      expect{profile.destroy}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe "get_full_name" do
    it "should be tested"
  end

  describe "before_destroy" do
    it "should be tested"
  end
end
