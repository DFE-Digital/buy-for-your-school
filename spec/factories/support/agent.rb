FactoryBot.define do
  factory :support_agent, class: "Support::Agent" do
    first_name { "John" }
    last_name { "Lennon" }
  end
end
