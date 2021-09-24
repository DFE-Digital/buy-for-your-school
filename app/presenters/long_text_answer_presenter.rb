class LongTextAnswerPresenter < BasePresenter
  include ActionView::Helpers::TextHelper

  # @return [String]
  def response
    simple_format(super)
  end

  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
