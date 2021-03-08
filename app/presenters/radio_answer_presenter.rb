class RadioAnswerPresenter < SimpleDelegator
  include AnswerHelper

  def response
    human_readable_option(string: super)
  end

  def to_param
    {
      response: response,
      further_information: further_information
    }
  end
end
