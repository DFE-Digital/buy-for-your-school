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

    it "doesn't allow invalid email formats" do
      support_case = create(:support_case)
      evaluator = build(:support_evaluator, support_case:)

      evaluator.email = "test.example.com"
      expect(evaluator).not_to be_valid

      evaluator.email = "@example.com"
      expect(evaluator).not_to be_valid

      evaluator.email = "example"
      expect(evaluator).not_to be_valid
    end

    it "does not allow more than 100 evaluators per support case" do
      support_case = create(:support_case)

      create_list(:support_evaluator, 100, support_case:)

      evaluator = build(:support_evaluator, support_case:, email: "extra@example.com")

      expect(evaluator).not_to be_valid
      expect(evaluator.errors[:base]).to include("Maximum number of evaluators reached")
    end

    it "does not allow more than 60 characters for first name and last name" do
      support_case = create(:support_case)

      evaluator = build(:support_evaluator, support_case:, first_name: "a" * 61)

      expect(evaluator).not_to be_valid
      expect(evaluator.errors[:first_name]).to include("First name must be 60 characters or fewer")

      evaluator = build(:support_evaluator, support_case:, last_name: "b" * 61)

      expect(evaluator).not_to be_valid
      expect(evaluator.errors[:last_name]).to include("Last name must be 60 characters or fewer")
    end
  end
end
