class CashHandover
  include Mongoid::Document
  include ModelAttributes

  CASH = 'Cash'
  CREDIT_CARD = 'Credit card'

  field :amount, type: BigDecimal
  field :currency, type: String
  field :conversion_rate, type: BigDecimal
  field :payment_mode, type: String, :default => CASH

  validates_presence_of :amount, :currency, :conversion_rate, :payment_mode
  # TODO: validates_inclusion of payment_mode in CASH, CREDIT_CARD
  belongs_to :expense_settlement

  def total_converted_amount
    self.amount * self.conversion_rate
  end
end
