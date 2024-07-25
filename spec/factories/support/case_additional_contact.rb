FactoryBot.define do
  factory :support_case_additional_contact, class: "Support::CaseAdditionalContact" do
    email { "school@email.co.uk" }
    first_name { "School" }
    last_name { "Contact" }
    role { "lead" }

    association :case, factory: :support_case
  end
end
