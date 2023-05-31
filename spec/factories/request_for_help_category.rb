FactoryBot.define do
  factory :request_for_help_category, class: "RequestForHelpCategory" do
    sequence(:title) { |n| "RFH Category #{n}" }
    description { "category description" }
    slug { nil }
    parent { nil }
    support_category { nil }
    archived { false }
    archived_at { nil }
  end
end
