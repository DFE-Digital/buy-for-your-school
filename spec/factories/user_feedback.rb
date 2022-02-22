FactoryBot.define do
  factory :user_feedback do
    service { :create_a_specification }
    satisfaction { :neither }
    feedback_text { "great service" }
    logged_in { false }
  end
end
