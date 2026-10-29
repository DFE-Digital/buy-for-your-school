FactoryBot.define do
  factory :energy_register_your_interest, class: "Energy::RegisterYourInterest" do
    name { "Alex Example" }
    email { "alex@example.com" }
    phone_number { "01234567890" }
    mat_uid { "MAT-123" }
    mat_name { "Example MAT" }
    ukprn { "12345678" }
    switch_gas { false }
    switch_electricity { false }
    status { :in_progress }
  end
end
