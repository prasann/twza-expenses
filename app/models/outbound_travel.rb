class OutboundTravel
  include Mongoid::Document

  field :emp_id, type: Integer    #TODO: Why is this in a different type than in other models? Also, why the different names?
  field :emp_name    #TODO: Why does this have a different name than in other models?
  field :place
  field :travel_duration
  field :payroll_effect
  field :departure_date, type: Date
  field :foreign_payroll_transfer
  field :return_date, type: Date
  field :return_payroll_transfer
  # TODO: Can this record exist without an expected_return_date? If it cant, then fix the validations and the factories.rb file
  field :expected_return_date #TODO: Convert to type: Date
  field :project
  field :comments
  field :actions

  has_one :expense_settlement

  validates_presence_of :emp_id, :emp_name, :departure_date, :place, :allow_blank => false

  class << self
    def get_json_to_populate(*args)
      # TODO: Can this be done with a 'group_by' and selecting only certain fields?
      outbound_travels = OutboundTravel.all
      args.inject({}) do |hash, field_name|
        hash[field_name] = outbound_travels.collect{|ot| ot[field_name].strip if ot[field_name].present?}.uniq.compact
        hash
      end
    end
  end

  # TODO: Isnt there a dynamic method that rails provides for this functionality?
  def find_or_initialize_expense_settlement
    self.create_expense_settlement if self.expense_settlement.nil?
    self.expense_settlement
  end

  def stay_duration
    date = self.return_date || DateHelper.date_from_str(self.expected_return_date)
    return (date - self.departure_date).to_i if date.present?
  end
end
