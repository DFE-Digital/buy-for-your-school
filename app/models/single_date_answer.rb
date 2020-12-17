class SingleDateAnswer < ActiveRecord::Base
  self.implicit_order_column = "created_at"
  belongs_to :step

  validates :response, presence: true
end
