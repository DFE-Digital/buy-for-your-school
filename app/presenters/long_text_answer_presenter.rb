class LongTextAnswerPresenter < SimpleDelegator
  include ActionView::Helpers::TextHelper

  def response
    simple_format(super)
  end
end
