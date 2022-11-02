class AllCasesSurveyResponsePresenter < BasePresenter
  def case_ref
    self.case&.ref
  end

  def case_state
    self.case&.state
  end

  def case_resolved?
    self.case&.state == "resolved"
  end

  def previous_satisfaction_response
    return if satisfaction_level.nil?

    I18n.t("all_cases_survey.satisfaction.options.#{satisfaction_level}").downcase
  end
end
