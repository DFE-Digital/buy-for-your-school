FactoryBot.define do
  factory :support_case_organisation, class: "Support::CaseOrganisation" do
    association :case, factory: :support_case
    association :organisation, factory: :support_organisation
  end
end
