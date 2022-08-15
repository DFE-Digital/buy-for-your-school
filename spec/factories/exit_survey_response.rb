FactoryBot.define do
  factory :exit_survey_response do
    satisfaction_level { "satisfied" }
    satisfaction_text { "reasons" }
    saved_time { "disagree" }
    better_quality { "agree" }
    future_support { "neither" }
    hear_about_service { "other" }
    hear_about_service_other { "elsewhere" }
    opt_in { true }
    opt_in_name { "name" }
    opt_in_email { "email" }

    association :case, factory: :support_case
  end
end
