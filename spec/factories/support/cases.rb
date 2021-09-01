FactoryBot.define do
  factory :support_case, class: "Support::Case" do
    ref { "MyString" }
    category_id { "" }
    sub_category_string { "MyString" }
    request_text { "MyString" }
    support_level { 1 }
    status { 1 }
    state { 1 }
  end
end
