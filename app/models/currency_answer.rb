# CurrencyAnswer is used to capture a currency answer to a {Step}.
class CurrencyAnswer < ApplicationRecord
  include TaskCounters

  belongs_to :step

  validates :response,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              message: "does not accept £ signs or other non numerical characters",
            }

  # Ensure no commas are present in the currency value
  #
  # @param [Float, String] value
  #
  # @return [Float]
  def response=(value)
    if value.is_a?(String)
      super(value.delete(","))
      return
    end
    super(value)
  end
end
