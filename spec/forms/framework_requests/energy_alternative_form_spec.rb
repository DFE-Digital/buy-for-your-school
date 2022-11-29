describe FrameworkRequests::EnergyAlternativeForm, type: :model do
  subject(:form) { described_class.new(energy_alternative:) }

  let(:energy_alternative) { nil }

  describe "validation" do
    describe "energy_alternative" do
      it { is_expected.to validate_presence_of(:energy_alternative) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:energy_alternative]).to eq ["Select how you would like to provide your energy information"]
        end
      end
    end
  end

  describe "#energy_alternative" do
    let(:energy_alternative) { "different_format" }

    it "returns the value as a symbol" do
      expect(form.energy_alternative).to eq :different_format
    end
  end

  describe "#energy_alternative_options" do
    it "returns the available options" do
      expect(form.energy_alternative_options).to eq %i[different_format email_later no_bill no_thanks]
    end
  end
end
