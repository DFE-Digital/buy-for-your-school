FactoryBot.define do
  factory :support_agent, class: "Support::Agent" do
    dsi_uid     { SecureRandom.uuid }
    first_name  { "first_name" }
    last_name   { "last_name" }
    internal    { false }
    roles       { %w[procops] }

    sequence(:email) { |n| sprintf("test.%04d@example.com", n) }

    trait :admin do
      roles { %w[admin] }
    end

    trait :internal do
      roles { %w[internal] }
    end

    trait :proc_ops do
      roles { %w[procops] }
    end

    trait :e_and_o do
      roles { %w[e_and_o] }
    end

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
