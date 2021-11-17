FactoryBot.define do
  factory :support_organisation, class: "Support::Organisation" do
    id { SecureRandom.uuid }
    urn { SecureRandom.hex[0..6] }
    sequence(:name) { |n| "School ##{n}" }
    address { {} }
    contact { {} }

    phase  { (0..7).to_a.sample }
    gender { (0..3).to_a.sample }
    status { (1..4).to_a.sample }

    association :establishment_type,
                factory: :support_establishment_type
  end
end
