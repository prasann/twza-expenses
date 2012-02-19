class CashHandover
  include Mongoid::Document
  include ModelAttributes

  field :amount, type: BigDecimal
  field :currency, type: String

  validates_presence_of :amount, :currency

  belongs_to :expense_settlement
end
