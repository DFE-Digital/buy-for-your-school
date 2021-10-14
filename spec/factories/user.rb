FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
    dfe_sign_in_uid { SecureRandom.uuid }

    email       { "test@test"   }
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

    after(:create, :build, :stub) do |user|
      if ENV["POST_MIGRATION_CHANGES"] == "true"
        user.email = nil
        user.full_name = nil
        user.first_name = nil
        user.last_name = nil
        user.orgs = nil
        user.roles = nil
      end
    end

    trait :unsupported do
      orgs do
        [{
          "id" => "23F20E54-79EA-4146-8E39-18197576F023",
          "name" => "Unsupported School Name",
          "type" => { "id" => "11" }, # ID will be rejected
        }]
      end
    end

    trait :caseworker do
      email       { "ops@education.gov.uk"   }
      first_name  { "Procurement"            }
      last_name   { "Specialist"             }
      orgs do
        [{
          "id" => "23F20E54-79EA-4146-8E39-18197576F023",
          "name" => "DSI Caseworkers",
        }]
      end
    end

    trait :with_multiple_supported_schools do
      orgs do
        [
          {
            "id": SecureRandom.uuid,
            "urn": SecureRandom.uuid,
            "name": "Specialist School for Testing",
            "type": { "id" => ORG_TYPE_IDS.first, "name" => "Community School" }
          },
          {
            "id": SecureRandom.uuid,
            "urn": SecureRandom.uuid,
            "name": "Greendale Academy for Bright Sparks",
            "type": { "id" => ORG_TYPE_IDS.last, "name" => "Academy Special Converter" }
          },
        ]
      end
    end

    trait :with_a_supported_school do
      orgs do
        [
          {
            "id": SecureRandom.uuid,
            "urn": SecureRandom.uuid,
            "name": "Specialist School for Testing",
            "type": { "id" => ORG_TYPE_IDS.first, "name" => "Community School" }
          },
        ]
      end
    end
  end
end
