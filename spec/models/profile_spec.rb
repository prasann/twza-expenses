require 'spec_helper'

describe Profile do
  let(:profile) { Profile.new(:common_name => "test", :employee_id => '1234', :email_id => 'test@xyz.com', :name => 'Mangatha Test') }

  describe "to_special_s" do
    it "should display name - id" do
      profile.to_special_s.should == 'test-1234'
    end
  end

  describe "readonly?" do
    it "should be readonly record" do
      expect{profile.save!}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end

    xit "should not be destroyable" do
      expect{profile.destroy}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
