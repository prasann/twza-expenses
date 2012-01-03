class Expense
  include Mongoid::Document

  field :emp_id, type: Integer
  field :emp_name 
end
