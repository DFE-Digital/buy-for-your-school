FactoryBot.define do
  factory :support_agent, class: "Support::Agent" do
    id          { SecureRandom.uuid }
    dsi_uid     { SecureRandom.uuid }
    email       { "test@test" }
    first_name  { "first_name" }
    last_name   { "last_name" }
  end
end
