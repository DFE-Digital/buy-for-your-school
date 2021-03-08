class LongTextAnswerPresenter < SimpleDelegator
  include ActionView::Helpers::TextHelper

  def response
    simple_format(super)
  end

  def to_param
    response
  end
end
