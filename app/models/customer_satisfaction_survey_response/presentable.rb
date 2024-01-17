module CustomerSatisfactionSurveyResponse::Presentable
  extend ActiveSupport::Concern

  included do
    satisfaction_levels.each_key do |level|
      define_method("satisfaction_text_#{level}") do
        satisfaction_level == level ? satisfaction_text : nil
      end
    end
  end
end
