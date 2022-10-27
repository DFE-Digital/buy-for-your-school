FactoryBot.define do
  factory :user_journey do
    status { :in_progress }
    referral_campaign { "test_campaign" }

    association :case, factory: :support_case
    association :framework_request, factory: :framework_request
  end
end
