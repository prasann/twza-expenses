require 'spec_helper'

describe UploadedExpense do
  describe "validations" do
    it { should validate_presence_of(:file_name) }
  end

  describe "fields" do
    let(:uploaded_expense) { Factory(:uploaded_expense) }

    it { should contain_field(:file_name, :type => String) }
  end
end
