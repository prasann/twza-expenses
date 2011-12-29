class Sample
  include Mongoid::Document

  field :title, type: String
  field :pub_date, type: Date
end
