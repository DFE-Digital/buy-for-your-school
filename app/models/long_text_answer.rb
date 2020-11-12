class LongTextAnswer < ActiveRecord::Base
  self.implicit_order_column = "created_at"
  belongs_to :question

  validates :response, presence: true
end
