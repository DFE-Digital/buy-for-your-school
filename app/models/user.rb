class User < ApplicationRecord
  self.implicit_order_column = "created_at"

  has_many :journeys
end
