FactoryBot.define do
  factory :framework_request do
    first_name { "David" }
    last_name { "Georgiou" }
    group { false }
    org_id { "000001" }
    email { "email@example.com" }
    message_body { "please help!" }
    submitted { false }
    procurement_amount { "10.50" }
    confidence_level { "confident" }
    special_requirements { "special_requirements" }
    is_energy_request { false }
    energy_request_about {}
    have_energy_bill {}
    energy_alternative {}
    category {}
    category_other {}
    origin { :recommendation }

    trait :energy_request do
      is_energy_request { true }
      energy_request_about { "energy_contract" }
      have_energy_bill { true }
    end
  end
end
