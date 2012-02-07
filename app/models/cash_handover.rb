require 'mongoid'

require "#{Rails.root}/lib/helpers/mongoid_helper"

class CashHandover
  include ApplicationHelper
  include Mongoid::Document
  include MongoidHelper

  field :amount, type: Float
  field :currency
  embedded_in :expense_settlement

end
