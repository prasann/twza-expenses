require 'mongoid'

require "#{Rails.root}/lib/helpers/model_attributes"

class CashHandover
  include ApplicationHelper
  include Mongoid::Document
  include ModelAttributes

  field :amount, type: BigDecimal
  field :currency, type: String

  validates_presence_of :amount, :currency

  belongs_to :expense_settlement

end
