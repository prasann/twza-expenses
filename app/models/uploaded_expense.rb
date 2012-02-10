class UploadedExpense
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :file_name

  validates_presence_of :file_name
end
