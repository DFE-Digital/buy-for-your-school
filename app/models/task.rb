class Task < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :section

  validates :title, :contentful_id, presence: true
end
