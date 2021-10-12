FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
    dfe_sign_in_uid { SecureRandom.uuid }

    # Tests covering data migration in production use factories
    if ENV["POST_MIGRATION_CHANGES"] == "true"
      email       { "test@test"   }
      full_name   { "full_name"   }
      first_name  { "first_name"  }
      last_name   { "last_name"   }

      orgs        { [] }
      # roles       { [] }
    end
  end
end
