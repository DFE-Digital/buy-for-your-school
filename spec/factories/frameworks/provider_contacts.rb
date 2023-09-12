FactoryBot.define do
  factory :frameworks_provider_contact, class: "Frameworks::ProviderContact" do
    name { "MyString" }
    email { "MyString" }

    association :provider, factory: :frameworks_provider
  end
end
