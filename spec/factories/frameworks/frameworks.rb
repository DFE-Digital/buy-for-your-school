FactoryBot.define do
  factory :frameworks_framework, class: "Frameworks::Framework" do
    association :provider, factory: :frameworks_provider
  end
end
