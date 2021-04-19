class Task < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :section
  has_many :steps
  has_many :visible_steps, -> { where(steps: {hidden: false}) }, class_name: "Step"

  validates :title, :contentful_id, presence: true
end
