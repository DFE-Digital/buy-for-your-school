class Journey < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :steps

  validates :liquid_template, presence: true
end
