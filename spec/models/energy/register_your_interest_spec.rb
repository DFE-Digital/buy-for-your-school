require "rails_helper"

RSpec.describe Energy::RegisterYourInterest do
  describe "step validations" do
    it "requires the name on the name step" do
      registration = described_class.new(step: "name")

      expect(registration).not_to be_valid
      expect(registration.errors).to include(:name)
    end

    it "requires a valid email on the email step" do
      registration = described_class.new(email: "not-an-email", step: "email")

      expect(registration).not_to be_valid
      expect(registration.errors).to include(:email)
    end

    it "rejects a phone number with fewer than 10 digits" do
      registration = described_class.new(phone_number: "1234 56789", step: "phone")

      expect(registration).not_to be_valid
      expect(registration.errors[:phone_number]).to include("Enter a telephone number, like 07155487611")
    end

    it "accepts a phone number containing 10 to 13 digits" do
      registration = described_class.new(phone_number: "0123456789", step: "phone")

      expect(registration).to be_valid
    end

    it "rejects phone numbers containing more than 13 digits" do
      registration = described_class.new(phone_number: "01234567890123", step: "phone")

      expect(registration).not_to be_valid
      expect(registration.errors[:phone_number]).to include("Enter a telephone number, like 07155487611")
    end

    it "rejects characters that are not permitted in phone numbers" do
      registration = described_class.new(phone_number: "01234abc890", step: "phone")

      expect(registration).not_to be_valid
      expect(registration.errors[:phone_number]).to include("Enter a telephone number, like 07155487611")
    end

    it "accepts formatted international phone numbers with 10 to 13 digits" do
      registration = described_class.new(phone_number: "+44 1234 567890", step: "phone")

      expect(registration).to be_valid
    end

    it "requires the contact details, MAT, and switch choices on the check answers step" do
      registration = described_class.new(step: "check-answers")

      expect(registration).not_to be_valid
      expect(registration.errors.attribute_names).to contain_exactly(:name, :email, :phone_number, :mat_uid, :switch_gas, :switch_electricity)
    end

    it "accepts false as a completed switch choice" do
      registration = described_class.new(
        name: "Alex Example",
        email: "alex@example.com",
        phone_number: "01234567890",
        mat_uid: "MAT-1",
        switch_gas: false,
        switch_electricity: false,
        step: "check-answers",
      )

      expect(registration).to be_valid
    end
  end
end
