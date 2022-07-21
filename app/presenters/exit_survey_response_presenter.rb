class ExitSurveyResponsePresenter < BasePresenter
  # Downcased previous satisfaction response
  #
  # @return [String]
  def previous_satisfaction_response
    I18n.t("exit_survey.satisfaction.options.#{satisfaction_level}").downcase
  end
end
