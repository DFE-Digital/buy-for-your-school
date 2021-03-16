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

  def further_information
    return unless super
    super["#{machine_readable_option(string: response)}_further_information"]
  end
end
