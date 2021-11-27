FactoryBot.define do
  factory :support_hub_transition, class: "Support::HubTransition" do
    hub_case_ref { "MyString" }
    estimated_procurement_completion_date { "2021-11-03" }
    estimated_savings { 10_000.00 }
    school_urn { "URN0001" }
    buying_category { "catering" }
  end
end
