FactoryBot.define do
  factory :support_enquiry, class: "Support::Enquiry" do
    support_request_id { "" }
  end
end
