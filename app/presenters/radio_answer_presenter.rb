class RadioAnswerPresenter < SimpleDelegator
  include AnswerHelper

  def response
    human_readable_option(string: super)
  end
end
