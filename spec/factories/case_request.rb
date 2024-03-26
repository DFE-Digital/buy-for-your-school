FactoryBot.define do
  factory :case_request do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    source { :digital }
    discovery_method { 0 }
    procurement_amount { 10 }
    association :category, factory: :support_category

    before(:create) do
      parent = create(:support_category, title: "Or")
      create(:support_category, title: "Other (General)", parent:)
      create(:support_query, title: "Other")
    end
  end
end
