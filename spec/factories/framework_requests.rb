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
  end
end
