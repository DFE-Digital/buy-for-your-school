RSpec.describe FrameworkRequest, type: :model do
  subject(:framework_request) { build(:framework_request, is_energy_request:, energy_request_about:, have_energy_bill:, energy_alternative:) }

  let(:is_energy_request) { false }
  let(:energy_request_about) { nil }
  let(:have_energy_bill) { false }
  let(:energy_alternative) { nil }

  it { is_expected.to belong_to(:user).optional }

  describe "#allow_bill_upload?" do
    context "when feature :energy_bill_flow is not enabled" do
      before { Flipper.disable(:energy_bill_flow) }

      it "returns false" do
        framework_request = described_class.new
        expect(framework_request.allow_bill_upload?).to be(false)
      end
    end

    context "when it's an energy request about a contract and they have a bill to upload" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :energy_contract }
      let(:have_energy_bill) { true }

      it "returns true" do
        expect(framework_request.allow_bill_upload?).to eq true
      end
    end

    context "when it's an energy request about a contract and they have a bill in a different format" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :energy_contract }
      let(:have_energy_bill) { false }
      let(:energy_alternative) { :different_format }

      it "returns true" do
        expect(framework_request.allow_bill_upload?).to eq true
      end
    end

    context "when it's not an energy request" do
      let(:is_energy_request) { false }

      it "returns false" do
        expect(framework_request.allow_bill_upload?).to eq false
      end
    end

    context "when it's an energy request not about a contract" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :not_energy_contract }

      it "returns false" do
        expect(framework_request.allow_bill_upload?).to eq false
      end
    end

    context "when it's an energy request about a contract but they don't have a bill in a different format" do
      let(:is_energy_request) { true }
      let(:energy_request_about) { :energy_contract }
      let(:have_energy_bill) { false }
      let(:energy_alternative) { :no_bill }

      it "returns false" do
        expect(framework_request.allow_bill_upload?).to eq false
      end
    end
  end

  describe "#has_bills?" do
    context "when there are associated energy bills" do
      before { create(:energy_bill, framework_request:) }

      it "returns true" do
        expect(framework_request.has_bills?).to eq true
      end
    end

    context "when there are no associated energy bills" do
      it "returns false" do
        expect(framework_request.has_bills?).to eq false
      end
    end
  end
end
