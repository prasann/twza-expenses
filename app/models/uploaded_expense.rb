class UploadedExpense
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :file_name
end
