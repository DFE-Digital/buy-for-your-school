class Plan < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :questions
end
