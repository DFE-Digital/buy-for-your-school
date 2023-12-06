FactoryBot.define do
  factory :user do
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
          "name": "Unsupported School bundleName",
          "type": { "id": "11", "name": "Other Independent School" },
        }]
      end
    end

    trait :one_supported_school do
      orgs do
        [{
          "urn": "100253",
          "name": "Specialist School for Testing",
          "type": { "id": ORG_TYPE_IDS.first, "name": "Community School" },
        }]
      end
    end

    trait :many_supported_schools do
      orgs do
        [
          {
            "urn": "100253",
            "name": "Specialist School for Testing",
            "type": { "id": ORG_TYPE_IDS.first, "name": "Community School" },
          },
          {
            "urn": "100254",
            "name": "Greendale Academy for Bright Sparks",
            "type": { "id": ORG_TYPE_IDS.last, "name": "Academy Special Converter" },
          },
        ]
      end
    end

    trait :one_supported_group do
      orgs do
        [{
          "uid": "2314",
          "name": "Testing Multi Academy Trust",
          "category": { "id": GROUP_CATEGORY_IDS.first, "name": "Multi-academy Trust" },
        }]
      end
    end

    trait :many_supported_schools_and_groups do
      orgs do
        [
          {
            "urn": "100253",
            "name": "Specialist School for Testing",
            "type": { "id": ORG_TYPE_IDS.first, "name": "Community School" },
          },
          {
            "urn": "100254",
            "name": "Greendale Academy for Bright Sparks",
            "type": { "id": ORG_TYPE_IDS.last, "name": "Academy Special Converter" },
          },
          {
            "uid": "2314",
            "name": "Testing Multi Academy Trust",
            "category": { "id": GROUP_CATEGORY_IDS.first, "name": "Multi-academy Trust" },
          },
          {
            "uid": "2315",
            "name": "New Academy Trust",
            "category": { "id": GROUP_CATEGORY_IDS.last, "name": "Single-academy Trust" },
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
