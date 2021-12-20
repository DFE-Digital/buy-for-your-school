FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
    dfe_sign_in_uid { SecureRandom.uuid }

    email       { "test@test"   }
    first_name  { "first_name"  }
    last_name   { "last_name"   }
    roles       { [] }

    orgs do
      [{
        "id": "23F20E54-79EA-4146-8E39-18197576F023",
        "name": "Supported School Name",
        "type": {
          "id": ORG_TYPE_IDS.sample.to_s, # random valid ids
        },
      }]
    end

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

    trait :caseworker do
      email       { "ops@education.gov.uk"   }
      first_name  { "Procurement"            }
      last_name   { "Specialist"             }
      orgs do
        [{
          "id": "23F20E54-79EA-4146-8E39-18197576F023",
          "name": "DSI Caseworkers",
        }]
      end
    end

    trait :no_supported_schools do
      orgs do
        [{
          "id": "23F20E54-79EA-4146-8E39-18197576F023",
          "name": "Unsupported School Name",
          "type": { "id": "11", "name": "Other Independent School" },
        }]
      end
    end

    trait :one_supported_school do
      orgs do
        [{
          "urn": "urn-type-1",
          "name": "Specialist School for Testing",
          "type": { "id": ORG_TYPE_IDS.first, "name": "Community School" },
        }]
      end
    end

    trait :many_supported_schools do
      orgs do
        [
          {
            "urn": "urn-type-1",
            "name": "Specialist School for Testing",
            "type": { "id": ORG_TYPE_IDS.first, "name": "Community School" },
          },
          {
            "urn": "greendale-urn",
            "name": "Greendale Academy for Bright Sparks",
            "type": { "id": ORG_TYPE_IDS.last, "name": "Academy Special Converter" },
          },
        ]
      end
    end

    trait :analyst do
      roles do
        %w[analyst]
      end
    end
  end
end
