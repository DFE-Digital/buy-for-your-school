class Section < ApplicationRecord
  self.implicit_order_column = "created_at"
  default_scope { order('created_at ASC') }

  belongs_to :journey
  has_many :tasks, dependent: :destroy
  has_many :steps, through: :tasks, class_name: "Step"

  validates :title, :contentful_id, presence: true
end
