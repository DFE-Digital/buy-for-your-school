require "rails_helper"

RSpec.describe Support::Email, type: :model do
  subject(:email) { build(:support_email) }

  it { is_expected.to belong_to(:case).optional }

  context "that has been assigned to a case" do
    it "does not create a new support interaction" do
      expect { subject.save! }.to change { Support::Interaction.where(event_type: "email_from_school").count }.by(0)
    end
  end

  context "that has not been assigned to a case" do
    it "does creates a new support interaction" do
      kase = create(:support_case)
      subject.case = kase

      expect { subject.save! }.to change { Support::Interaction.where(event_type: "email_from_school").count }.by(1)
    end
  end
end
