RSpec.describe Support::ContractRecipient, type: :model do
  describe "validation" do
    it "enforces case insensitive email uniqueness" do
      support_case = create(:support_case)
      create(:support_contract_recipient, support_case:, email: "test@example.com")
      contract_recipient = build(:support_contract_recipient, support_case:)

      contract_recipient.email = "TEST@example.com"
      expect(contract_recipient).not_to be_valid

      contract_recipient.email = "different@example.com"
      expect(contract_recipient).to be_valid
    end

    it "scopes email uniqueness by case" do
      case_a = create(:support_case)
      case_b = create(:support_case)
      create(:support_contract_recipient, support_case: case_a, email: "test@example.com")

      contract_recipient = build(:support_contract_recipient, support_case: case_a, email: "test@example.com")
      expect(contract_recipient).not_to be_valid

      contract_recipient.support_case = case_b
      expect(contract_recipient).to be_valid
    end

    it "doesn't allow invalid email formats" do
      support_case = create(:support_case)
      contract_recipient = build(:support_contract_recipient, support_case:)

      contract_recipient.email = "test.example.com"
      expect(contract_recipient).not_to be_valid

      contract_recipient.email = "@example.com"
      expect(contract_recipient).not_to be_valid

      contract_recipient.email = "example"
      expect(contract_recipient).not_to be_valid
    end

    it "does not allow more than 100 contract recipients per support case" do
      support_case = create(:support_case)

      create_list(:support_contract_recipient, 100, support_case:)

      contract_recipient = build(:support_contract_recipient, support_case:, email: "extra@example.com")

      expect(contract_recipient).not_to be_valid
      expect(contract_recipient.errors[:base]).to include("Maximum number of contract recipients reached")
    end

    it "does not allow more than 60 characters for first name and last name" do
      support_case = create(:support_case)

      contract_recipient = build(:support_contract_recipient, support_case:, first_name: "a" * 61)

      expect(contract_recipient).not_to be_valid
      expect(contract_recipient.errors[:first_name]).to include("First name must be 60 characters or fewer")

      contract_recipient = build(:support_contract_recipient, support_case:, last_name: "b" * 61)

      expect(contract_recipient).not_to be_valid
      expect(contract_recipient.errors[:last_name]).to include("Last name must be 60 characters or fewer")
    end
  end
end
