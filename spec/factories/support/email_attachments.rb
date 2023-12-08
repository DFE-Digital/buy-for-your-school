FactoryBot.define do
  factory :support_email_attachment, parent: :email_attachment do
    sequence(:outlook_id, &:to_s)
  end
end
