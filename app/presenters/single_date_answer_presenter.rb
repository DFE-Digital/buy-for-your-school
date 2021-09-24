class SingleDateAnswerPresenter < BasePresenter
  # @return [String]
  def response
    I18n.l(super)
  end

  # @return [Hash]
  def to_param
    {
      response: response,
    }
  end
end
