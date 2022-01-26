FactoryBot.define do
  factory :support_establishment_group_type, class: "Support::EstablishmentGroupType" do
    sequence(:name) { |n| "name #{n}" }
    sequence(:code) { |n| n }
  end
end
