FactoryBot.define do
  factory :support_procurement_stage, class: "Support::ProcurementStage" do
    title { "Test stage" }
    key { "test_stage" }
    stage { 0 }
    archived { false }

    trait :form_review do
      title { "Form review" }
      key { "form_review" }
      stage { 6 }
      archived { false }
    end

    trait :with_supplier do
      title { "With supplier" }
      key { "with_supplier" }
      stage { 6 }
      archived { false }
    end
  end
end
