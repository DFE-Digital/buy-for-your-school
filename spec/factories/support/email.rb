FactoryBot.define do
  factory :support_email, class: "Support::Email" do
    subject { "Support Case #001" }

    body { "<html><head></head><body><h1>My support request</h1><p>Please update my case</p></body></html>" }
    sender { { address: "sender1@email.com", name: "Sender 1" } }
    recipients { [{ address: "recipient1@email.com", name: "Recipient 1" }] }
    outlook_conversation_id { "MyString" }
    case_id { "" }
    sent_at { "2021-12-15 11:51:12" }
    outlook_received_at { "2021-12-15 11:51:12" }
    outlook_read_at { "2021-12-15 11:51:12" }
    is_read { false }
    association :case, factory: :support_case

    trait :inbox do
      folder { :inbox }
    end

    trait :sent_items do
      folder { :sent_items }
    end
  end
end
