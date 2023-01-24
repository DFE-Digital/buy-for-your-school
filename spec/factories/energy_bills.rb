FactoryBot.define do
  factory :energy_bill do
    submission_status { :pending }
    filename { "MyString" }
    filesize { 1 }

    association :framework_request, factory: :framework_request

    trait :pending do
      submission_status { :pending }
    end

    trait :submitted do
      submission_status { :submitted }
    end
  end
end
