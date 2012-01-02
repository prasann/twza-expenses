class ForexPayment
  include Mongoid::Document

  field :issue_date, type: Date
  field :emp_id, type: Integer
  field :emp_name
  field :amount, type: BigDecimal
  field :currency
  field :travel_date, type: Date
  field :place
  field :project
  field :vendor_name
  field :card_number
  field :expiry_date, type: Date
  field :office
  field :inr, type: BigDecimal
end
