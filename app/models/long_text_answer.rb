class LongTextAnswer < ApplicationRecord
  include TaskCounters

  self.implicit_order_column = "created_at"
  belongs_to :step

  validates :response, presence: true
end
