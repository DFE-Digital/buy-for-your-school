#
# Base form object for exit survey forms
#
class ExitSurvey::Form < Form
  # @return [Hash] form params as request attributes
  def data
    to_h.except(:user, :step, :messages)
  end
end
