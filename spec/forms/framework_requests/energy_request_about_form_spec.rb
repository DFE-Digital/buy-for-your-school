describe FrameworkRequests::EnergyRequestAboutForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, energy_request_about:) }

  let(:framework_request) { create(:framework_request) }
  let(:energy_request_about) { nil }

  describe "validation" do
    describe "energy_request_about" do
      it { is_expected.to validate_presence_of(:energy_request_about) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:energy_request_about]).to eq ["Select what your energy request is about"]
        end
      end
    end
  end

  describe "#data" do
    context "when the request is about a contract" do
      let(:energy_request_about) { :energy_contract }

      it "returns the energy_request_about value" do
        expect(form.data).to eq({ energy_request_about: :energy_contract })
      end
    end

    context "when the request is not about a contract" do
      let(:energy_request_about) { :not_energy_contract }

      it "returns other energy fields nillified" do
        expect(form.data).to eq({ energy_request_about: :not_energy_contract, have_energy_bill: nil, energy_alternative: nil })
      end
    end
  end

  describe "#energy_request_about" do
    let(:energy_request_about) { "energy_contract" }

    it "returns the value as a symbol" do
      expect(form.energy_request_about).to eq :energy_contract
    end
  end

  describe "#energy_request_about_options" do
    it "returns the available options" do
      expect(form.energy_request_about_options).to eq %w[energy_contract not_energy_contract]
    end
  end
end
