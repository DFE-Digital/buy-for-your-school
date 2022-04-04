FactoryBot.define do
  factory :support_framework, class: "Support::Framework" do
    name { "Test framework" }
    supplier { "Test supplier" }
    category { "Test category" }
    expires_at { "2022-12-02" }
  end
end
