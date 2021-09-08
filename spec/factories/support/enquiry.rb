FactoryBot.define do
  factory :support_enquiry, class: "Support::Enquiry" do
    support_request_id { SecureRandom.uuid }
    name { "Bruce Wayne" }
    email { "bruce.wayne.gov.uk" }
    telephone { "0151 000 0000" }
    category { "Catering Support" }
    message { "This is an example request for support - please help!" }
  end
end
