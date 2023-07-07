FactoryBot.define do
  factory :support_framework, class: "Support::Framework" do
    sequence(:name) { |n| "Test framework #{n}" }
    supplier { "Test supplier" }
    category { "Test category" }
    expires_at { "2022-12-02" }
    sequence(:ref) { |n| "test-#{n}" }
  end
end
