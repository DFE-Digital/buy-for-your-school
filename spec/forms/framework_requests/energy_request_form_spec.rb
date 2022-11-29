describe FrameworkRequests::EnergyRequestForm, type: :model do
  subject(:form) { described_class.new(is_energy_request:) }

  describe "validation" do
    describe "is_energy_request" do
      let(:is_energy_request) { nil }

      it { is_expected.to validate_presence_of(:is_energy_request) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:is_energy_request]).to eq ["Select whether your request is about energy"]
        end
      end
    end
  end

  describe "#is_energy_request?" do
    context "when it is an energy request" do
      let(:is_energy_request) { "true" }

      it "returns true" do
        expect(form.is_energy_request?).to eq true
      end
    end

    context "when it is not an energy request" do
      let(:is_energy_request) { "false" }

      it "returns false" do
        expect(form.is_energy_request?).to eq false
      end
    end
  end
end
