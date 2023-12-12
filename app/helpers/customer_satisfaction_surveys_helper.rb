module CustomerSatisfactionSurveysHelper
  def available_satisfaction_levels
    CustomerSatisfactionSurveyResponse.satisfaction_levels.keys.reverse
  end

  def available_easy_to_use_ratings
    CustomerSatisfactionSurveyResponse.easy_to_use_ratings.keys.reverse
  end

  def available_helped_how_options
    CheckboxOption.from(I18nOption.from("customer_satisfaction_survey.helped_how.options.%%key%%", CustomerSatisfactionSurveyResponse.helped_how_values), exclusive_fields: %w[none])
  end

  def available_clear_to_use_ratings
    CustomerSatisfactionSurveyResponse.clear_to_use_ratings.keys.reverse
  end

  def available_recommendation_likelihood_ratings
    10.downto(0).map(&:to_s)
  end
end
