class Section < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :journey
  has_many :tasks

  validates :title, :contentful_id, presence: true
end
