FactoryBot.define do
  factory :support_establishment_group, class: "Support::EstablishmentGroup" do
    sequence(:name) { |n| "Group ##{n}" }
    ukprn { "1010010" }
    status { [0, 1, 2].sample }
    uid { "1234" }
    establishment_group_type_id { "abc1111" }
    address { { "town": "London", "county": "", "street": "Boundary House Shr", "locality": "91 Charter House Street", "postcode": "EC1M 6HR" } }
    association :establishment_group_type,
                factory: :support_establishment_group_type
  end
end
