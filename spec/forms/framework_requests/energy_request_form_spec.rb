describe FrameworkRequests::EnergyRequestForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, is_energy_request:) }

  let(:framework_request) { create(:framework_request) }

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

  describe "#data" do
    context "when it is an energy request" do
      let(:is_energy_request) { true }

      it "returns the is_energy_request value" do
        expect(form.data).to eq({ is_energy_request: true })
      end
    end

    context "when it is not an energy request" do
      let(:is_energy_request) { false }

      it "returns other energy fields nillified" do
        expect(form.data).to eq({ is_energy_request: false, energy_request_about: nil, have_energy_bill: nil, energy_alternative: nil })
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
