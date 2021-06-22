class CurrencyAnswer < ActiveRecord::Base
  include TaskCounters

  self.implicit_order_column = "created_at"
  belongs_to :step

  validates :response, presence: true, numericality: {greater_than_or_equal_to: 0, message: "does not accept £ signs or other non numerical characters"}

  def response=(value)
    if value.is_a?(String)
      super(value.delete(","))
      return
    end
    super(value)
  end
end
