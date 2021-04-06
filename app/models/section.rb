class Section < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :journey

  validates :title, presence: true
end
