class CurrencyAnswerPresenter < SimpleDelegator
  include ActionView::Helpers::NumberHelper

  def response
    number_to_currency(super, unit: "£", precision: 2)
  end
end
