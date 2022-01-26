FactoryBot.define do
  factory :support_establishment_group, class: 'Support::Group' do
    sequence(:name) { |n| "Group ##{n}" }
    ukprn { "1010010" }
    status { [0, 1, 2].sample }
    address { { "town": "London", "county": "", "street": "St James's Passage", "locality": "Duke's Place", "postcode": "EC3A 5DE" } }
    association :establishment_group_type,
                factory: :support_establishment_group_type
  end
end
