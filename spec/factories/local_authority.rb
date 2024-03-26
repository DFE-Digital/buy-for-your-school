FactoryBot.define do
  factory :local_authority, class: "LocalAuthority" do
    la_code { Faker::Number.unique.number(digits: 3).to_s }
    name { Faker::Address.unique.city }
  end
end
