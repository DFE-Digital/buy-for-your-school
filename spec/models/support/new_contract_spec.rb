require "rails_helper"

RSpec.describe Support::NewContract, type: :model do
  it { is_expected.to have_one(:support_case) }

  describe "#calculate_ended_at" do
    let(:contract) { build(:support_new_contract, started_at: nil, duration: nil) }

    context "when started_at and duration are present" do
      it "calculates ended_at when saved" do
        contract.duration = 24.months
        contract.started_at = Date.parse("2022-01-20")
        contract.save!

        expect(contract.ended_at).to eq Date.parse("2024-01-20")
      end
    end

    context "when started_at and duration are nil" do
      it "returns nil" do
        contract.save!

        expect(contract.ended_at).to be_nil
      end
    end
  end
end
