class OutboundTravel
  include Mongoid::Document
  
  field :emp_id, type: Integer
  field :emp_name
  field :place
  field :travel_duration
  field :payroll_effect
  field :departure_date, type: Date
  field :foreign_payroll_transfer, type: Date
  field :return_date, type: Date
  field :return_payroll_transfer, type: Date
  field :expected_return_date, type: Date
  field :project
  field :comments
  field :actions


  validates_presence_of :emp_id, :emp_name, :departure_date, :expected_return_date
end
