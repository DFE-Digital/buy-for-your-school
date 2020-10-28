class Question < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :plan
  has_one :answer
end
