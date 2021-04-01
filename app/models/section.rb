class Section < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :journey
  has_many :tasks

  validates :title, presence: true
end
