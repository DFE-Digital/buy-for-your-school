FactoryBot.define do
  factory :user_journey_step do
    session_id { SecureRandom.uuid }
    product_section { :faf }
    step_description { "test_step" }

    association :user_journey, factory: :user_journey
  end
end
