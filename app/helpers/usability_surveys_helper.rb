module UsabilitySurveysHelper
  def usability_survey_usage_reason_options
    CheckboxOption.from(
      I18nOption.from(
        "usability_survey.usage_reasons.options.%%key%%",
        %w[browsing finding_a_framework guidance request_for_help other],
      ),
    )
  end
end
