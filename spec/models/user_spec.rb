require 'spec_helper'

describe User do
  describe "validations" do
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:user_name) }

    it "should validate uniqueness of user_name" do
      Factory(:user)
      should validate_uniqueness_of(:user_name).with_message('is already taken')
    end

  # validates_confirmation_of :password

  end

  describe "relationships" do
    xit { should belong_to(:expense_settlement) }
  end

  describe "fields" do
    let(:user) { Factory(:user) }

    it { should contain_field(:user_name, :type => String) }
    it { should contain_field(:password_hash, :type => String) }
    it { should contain_field(:password_salt, :type => String) }
    it { should contain_field(:role, :type => String) }
  end

  describe "before_save" do
    it "should be tested"
  end

  describe "authenticate" do
    it "should be tested"
  end

  describe "admin?" do
    it "should be tested"
  end

  describe "superadmin?" do
    it "should be tested"
  end
end
