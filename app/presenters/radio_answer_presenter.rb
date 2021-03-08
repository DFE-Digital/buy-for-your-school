class RadioAnswerPresenter < SimpleDelegator
  include AnswerHelper

  def response
    human_readable_option(string: super)
  end

  def to_param
    response
  end
end
