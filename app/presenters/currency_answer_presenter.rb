class CurrencyAnswerPresenter < BasePresenter
  include ActionView::Helpers::NumberHelper

  # @return [String]
  def response
    number_to_currency(super, unit: "£", precision: 2)
  end

  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
