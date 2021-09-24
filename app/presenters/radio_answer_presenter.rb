class RadioAnswerPresenter < BasePresenter
  include AnswerHelper

  # @return [Hash<Symbol>]
  def to_param
    {
      response: response,
      further_information: further_information,
    }
  end

  # @return [String]
  def response
    human_readable_option(string: super)
  end

  # @return [Nil, String]
  def further_information
    return unless super

    super["#{machine_readable_option(string: response)}_further_information"]
  end
end
