class ForexPayment
  include Mongoid::Document

  INVALID_CREDIT_CARD_MSG = "Not a valid 16-digit credit-card number"
  MISSING_EXPIRY_DATE_MSG = "Card number should have an expiry date specified"

  field :issue_date, type: Date
  field :emp_id, type: Integer    #TODO: Why is this in a different type than in other models? Also, why the different names?
  field :emp_name    #TODO: Why does this have a different name than in other models?
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

  validates_presence_of :emp_id, :emp_name, :amount, :currency, :travel_date, :inr, :issue_date, :vendor_name

  class << self
    def for_emp_id(emp_id)
      where(:emp_id => emp_id)
    end

    def fetch_for(empl_id, date_from, date_to, forex_ids_to_be_excluded)
      for_emp_id(empl_id).and(:travel_date.gte => date_from).and(:travel_date.lte => date_to).not_in(_id: forex_ids_to_be_excluded).to_a
    end

    def get_json_to_populate(*args)
      # TODO: Can this be done with a 'group_by' and selecting only certain fields?
      forex_payments = ForexPayment.all
      args.inject({}) do |hash, field_name|
        hash[field_name] = forex_payments.collect{|fp| fp[field_name].strip if fp[field_name].present?}.uniq.compact
        hash
      end
    end
  end

  def convert_inr(conversion_factor)
    conversion_factor = conversion_factor || 1
    ((amount.to_f * conversion_factor) * 100).round.to_f/100
  end

  def conversion_rate
    self.inr/self.amount
  end

  def expiry_date=(value)
    begin
      self[:expiry_date] = Time.strptime(value, '%m/%y')
    rescue
      self[:expiry_date] = nil
    end
  end
end
