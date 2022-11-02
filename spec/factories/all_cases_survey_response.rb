FactoryBot.define do
  factory :all_cases_survey_response do
    satisfaction_level { "satisfied" }
    satisfaction_text { "reasons" }
    outcome_achieved { "agree" }
    about_outcomes_text { "outcomes" }
    improve_text { "improvements" }
    accessibility_research_opt_in { false }
    status { "in_progress" }

    association :case, factory: :support_case
  end
end
