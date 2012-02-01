class BankDetail
  include Mongoid::Document

  field :empl_id, type: String
  field :empl_name, type: String
  field :account_no, type: Integer

  validates_presence_of :empl_id, :account_no

  class << self
    def for_empl_id(empl_id)
      where(:empl_id => empl_id)
    end
  end
end
