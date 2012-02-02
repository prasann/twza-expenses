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
  field :expiry_date
  field :office
  field :inr, type: BigDecimal

  validates_presence_of :emp_id, :emp_name, :amount, :currency, :travel_date, :inr

  class << self
    def for_emp_id(emp_id)
      where(:emp_id => emp_id)
    end
  end

  def self.fetch_for(empl_id, date_from, date_to, forex_ids_to_be_excluded)
    ForexPayment.for_emp_id(empl_id).and("travel_date" => {"$gte" => date_from, "$lte" => date_to}).not_in(_id: forex_ids_to_be_excluded).to_a
  end

  def convert_inr(conversion_factor)
    conversion_factor = conversion_factor || 1
    ((amount.to_f * conversion_factor) * 100).round.to_f/100
  end
end
