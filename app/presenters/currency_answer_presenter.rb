class CurrencyAnswerPresenter < BasePresenter
  include ActionView::Helpers::NumberHelper

  # @return [String]
  def response
    number_to_currency(super, unit: "£", precision: 2)
  end

  # A hash of options used in Liquid templates to aid
  # content designers when implementing step logic.
  #
  # @see GetAnswersForSteps
  #
  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
