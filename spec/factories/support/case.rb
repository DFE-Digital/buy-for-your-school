FactoryBot.define do
  factory :support_case, class: "Support::Case" do
    ref { "" }
    request_text { "This is an example request for support - please help!" }
    state { 0 }
    support_level { 0 }

    association :enquiry, factory: :support_enquiry
    association :category, factory: :support_category
    sub_category_string { "category subtitle" }
  end
end
