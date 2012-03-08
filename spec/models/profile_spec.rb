require 'spec_helper'

describe Profile do
  let(:profile) { Profile.new(:common_name => "test", :employee_id => '1234', :email_id => 'test@xyz.com', :name => 'Mangatha Test') }

  describe "readonly?" do
    it "should be readonly record" do
      expect{profile.save!}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end

    xit "should not be destroyable" do
      expect{profile.destroy}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end
end
