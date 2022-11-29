describe FrameworkRequests::EnergyRequestAboutForm, type: :model do
  subject(:form) { described_class.new(energy_request_about:) }

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

  describe "#energy_request_about" do
    let(:energy_request_about) { "energy_contract" }

    it "returns the value as a symbol" do
      expect(form.energy_request_about).to eq :energy_contract
    end
  end

  describe "#energy_request_about_options" do
    it "returns the available options" do
      expect(form.energy_request_about_options).to eq %i[energy_contract general_question something_else]
    end
  end
end
