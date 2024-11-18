FactoryBot.define do
  factory :support_establishment_group, class: "Support::EstablishmentGroup" do
    sequence(:name) { |n| "Group ##{n}" }
    ukprn { "1010010" }
    status { 1 }
    sequence(:uid, &:to_s)
    establishment_group_type_id { "abc1111" }
    association :establishment_group_type,
                factory: :support_establishment_group_type

    address { {} }
    archived { false }

    trait :with_no_address do
      address { { "town": "", "county": "", "street": "", "locality": "", "postcode": "" } }
    end

    trait :with_address do
      address { { "town": "London", "county": "", "street": "Boundary House Shr", "locality": "91 Charter House Street", "postcode": "EC1M 6HR" } }
    end
  end
end
