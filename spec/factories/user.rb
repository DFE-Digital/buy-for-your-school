FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
    dfe_sign_in_uid { SecureRandom.uuid }
    email       { "test@test"   }
    full_name   { "full_name"   }
    first_name  { "first_name"  }
    last_name   { "last_name"   }
    orgs do
      [{
        "id" => "23F20E54-79EA-4146-8E39-18197576F023",
        "name" => "Supported School Name",
        "type" => {
          "id" => ORG_TYPE_IDS.sample.to_s, # random valid ids
        },
      }]
    end

    roles { [] }

    trait :unsupported do
      orgs do
        [{
          "id" => "23F20E54-79EA-4146-8E39-18197576F023",
          "name" => "Unsupported School Name",
          "type" => {
            "id" => "11",
          },
        }]
      end
    end
  end
end
