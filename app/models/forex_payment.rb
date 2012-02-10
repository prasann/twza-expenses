class ForexPayment
  include Mongoid::Document

  INVALID_CREDIT_CARD_MSG = "Not a valid 16-digit credit-card number"
  MISSING_EXPIRY_DATE_MSG = "Card number should have an expiry date specified"

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

  validate :verify_credit_card_details

  validates_presence_of :emp_id, :emp_name, :amount, :currency, :travel_date, :inr, :issue_date, :vendor_name

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

  def expiry_date=(value)
    begin
      self[:expiry_date] = Time.strptime(value, '%m/%y')
    rescue
      self[:expiry_date] = nil
    end
  end

  private
  def verify_credit_card_details
    if (!card_number.blank? && (/^\d{16}[^\d]+/ =~ card_number.gsub(" ", "")).blank?)
      self.errors.add(:card_number, INVALID_CREDIT_CARD_MSG)
    end
  end
end
