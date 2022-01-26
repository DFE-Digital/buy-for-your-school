FactoryBot.define do
  factory :framework_request do
    first_name { "David" }
    last_name { "Georgiou" }
    school_urn { "000001" }
    email { "email@example.com" }
    message_body { "please help!" }
    submitted { false }

  end
end
