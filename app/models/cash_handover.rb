require 'mongoid'

require "#{Rails.root}/lib/helpers/mongoid_helper"

class CashHandover
  include ApplicationHelper
  include Mongoid::Document
  include MongoidHelper

  field :amount, type: Float
  field :currency
  belongs_to :expense_settlement

end
