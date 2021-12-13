FactoryBot.define do
  factory :support_new_contract, class: "Support::NewContract" do
    initialize_with { type.present? ? type.constantize.new : Support::NewContract.new }

    supplier { "ACME Corp" }
    started_at { "2020-12-01" }
    ended_at { "" }
    duration { "" }
    spend { "9.99" }
    type { "" }
  end
end
