class ExitSurveyResponsePresenter < BasePresenter
  # Downcased previous satisfaction response
  #
  # @return [String, nil]
  def previous_satisfaction_response
    return if satisfaction_level.nil?

    I18n.t("exit_survey.satisfaction.options.#{satisfaction_level}").downcase
  end
end
