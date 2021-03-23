FactoryBot.define do
  factory :user do
    dfe_sign_in_uid { SecureRandom.uuid }
  end
end
