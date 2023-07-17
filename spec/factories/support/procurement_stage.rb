FactoryBot.define do
  factory :support_procurement_stage, class: "Support::ProcurementStage" do
    title { "Test stage" }
    key { "test_stage" }
    stage { 0 }
    archived { false }
  end
end
