class BankDetail
  include Mongoid::Document

  field :empl_id, type: String    #TODO: Why is this in a different type than in other models? Also, why the different names?
  field :empl_name, type: String    #TODO: Why does this have a different name than in other models?
  field :account_no, type: Integer

  validates_presence_of :empl_id, :empl_name, :account_no, :allow_blank => false
  validates_uniqueness_of :account_no

  class << self
    def for_empl_id(empl_id)
      where(:empl_id => empl_id)
    end
  end
end
