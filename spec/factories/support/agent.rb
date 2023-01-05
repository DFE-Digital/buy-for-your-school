FactoryBot.define do
  factory :support_agent, class: "Support::Agent" do
    id          { SecureRandom.uuid }
    dsi_uid     { SecureRandom.uuid }
    email       { "test@test" }
    first_name  { "first_name" }
    last_name   { "last_name" }
    internal    { false }

    after(:create) do |agent|
      if agent.user.blank?
        create(:user,
               first_name: agent.first_name,
               last_name: agent.first_name,
               email: agent.email,
               dfe_sign_in_uid: agent.dsi_uid)
      end
    end
  end
end
