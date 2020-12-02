class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :steps
end
