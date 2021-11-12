FactoryBot.define do
  factory :support_establishment_type, class: "Support::EstablishmentType" do
    sequence(:name) { |n| "name #{n}" }
    sequence(:code) { |n| n }

    association :group,
                factory: :support_group
  end
end
