FactoryBot.define do
  factory :framework_request do
    first_name { "David" }
    last_name { "Georgiou" }
    group { false }
    school_urn { "000001" }
    group_uid { "1234" }
    email { "email@example.com" }
    message_body { "please help!" }
    submitted { false }
  end
end
