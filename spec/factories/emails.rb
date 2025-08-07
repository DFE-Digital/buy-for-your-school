FactoryBot.define do
  factory :email, class: "Email" do
    subject { "Support Case #001" }

    body { "<html><head></head><body><h1>My support request</h1><p>Please update my case</p></body></html>" }
    sender { { address: "sender1@email.com", name: "Sender 1" } }
    recipients { [{ address: "recipient1@email.com", name: "Recipient 1" }] }
    to_recipients { [{ address: "to_recipient@email.com", name: "To Recipient" }] }
    cc_recipients { [{ address: "cc_recipient@email.com", name: "CC Recipient" }] }
    bcc_recipients { [{ address: "bcc_recipient@email.com", name: "BCC Recipient" }] }
    outlook_conversation_id { "MyString" }
    case_id { "" }
    sent_at { "2021-12-15 11:51:12" }
    outlook_received_at { "2021-12-15 11:51:12" }
    outlook_read_at { "2021-12-15 11:51:12" }
    is_read { false }
    template { nil }

    association :ticket, factory: :support_case

    trait :inbox do
      folder { :inbox }
    end

    trait :sent_items do
      folder { :sent_items }
    end

    trait :draft do
      is_draft { true }
    end
  end
end
