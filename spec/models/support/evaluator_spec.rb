RSpec.describe Support::Evaluator, type: :model do
  describe "validation" do
    it "enforces case insensitive email uniqueness" do
      support_case = create(:support_case)
      create(:support_evaluator, support_case:, email: "test@example.com")
      evaluator = build(:support_evaluator, support_case:)

      evaluator.email = "TEST@example.com"
      expect(evaluator).not_to be_valid

      evaluator.email = "different@example.com"
      expect(evaluator).to be_valid
    end

    it "scopes email uniqueness by case" do
      case_a = create(:support_case)
      case_b = create(:support_case)
      create(:support_evaluator, support_case: case_a, email: "test@example.com")

      evaluator = build(:support_evaluator, support_case: case_a, email: "test@example.com")
      expect(evaluator).not_to be_valid

      evaluator.support_case = case_b
      expect(evaluator).to be_valid
    end
  end
end