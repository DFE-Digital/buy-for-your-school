FactoryBot.define do
  factory :energy_bill do
    submission_status { :pending }
    filename { "MyString" }
    filesize { 1 }

    trait :pending do
      submission_status { :pending }
    end

    trait :submitted do
      submission_status { :submitted }
    end
  end
end
