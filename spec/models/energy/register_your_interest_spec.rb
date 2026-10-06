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
