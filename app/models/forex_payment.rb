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

  def self.fetch_for(empl_id, date_from, date_to)
	emp_forex = ForexPayment.where(emp_id: empl_id).and("travel_date" => {"$gte" => date_from, "$lte" => date_to}).to_a
	return emp_forex
  end
end
