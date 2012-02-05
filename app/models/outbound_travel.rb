class OutboundTravel
  include Mongoid::Document

  field :emp_id, type: Integer
  field :emp_name
  field :place
  field :travel_duration
  field :payroll_effect
  field :departure_date, type: Date
  field :foreign_payroll_transfer
  field :return_date, type: Date
  field :return_payroll_transfer
  field :expected_return_date #TODO: Convert to type: Date
  field :project
  field :comments
  field :actions

  has_one :expense_settlement

  validates_presence_of :emp_id, :emp_name, :departure_date

  def find_or_initialize_expense_settlement
    self.create_expense_settlement if self.expense_settlement.nil?
    self.expense_settlement
  end

  def stay_duration
    date = self.return_date || DateHelper.date_from_str(self.expected_return_date)
    return (date - self.departure_date).to_i if date.present?
  end
end
