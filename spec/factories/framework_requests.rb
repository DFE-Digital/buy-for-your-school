FactoryBot.define do
  factory :framework_request do
    first_name { "David" }
    last_name { "Georgiou" }
    group { false }
    school_urn { "000001" }
    email { "email@example.com" }
    message_body { "please help!" }
    submitted { false }
  end
end
