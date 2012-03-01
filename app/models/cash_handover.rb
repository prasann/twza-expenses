class CashHandover
  include Mongoid::Document
  include ModelAttributes

  field :amount, type: BigDecimal
  field :currency, type: String
  field :conversion_rate, type: BigDecimal

  validates_presence_of :amount, :currency, :conversion_rate

  belongs_to :expense_settlement
end
