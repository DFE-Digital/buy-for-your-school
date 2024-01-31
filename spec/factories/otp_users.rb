FactoryBot.define do
  factory :otp_user do
    email { "MyString" }
    otp_secret_key { "MyString" }
    last_otp_at { 1 }
  end
end
