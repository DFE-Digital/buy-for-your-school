require "rails_helper"

RSpec.describe Support::ExistingContract, type: :model do
  it { is_expected.to have_one(:support_case) }

  describe "#calculate_started_at" do
    let(:contract) { build(:support_existing_contract, ended_at: nil, duration: nil) }

    context "when ended_at and duration are present" do
      it "calculates started_at when saved" do
        contract.duration = 24.months
        contract.ended_at = Date.parse("2022-01-20")
        contract.save!

        expect(contract.started_at).to eq Date.parse("2020-01-20")
      end
    end

    context "when ended_at and duration are nil" do
      it "returns nil" do
        contract.save!

        expect(contract.started_at).to be_nil
      end
    end
  end
end
