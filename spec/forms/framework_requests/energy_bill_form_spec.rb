describe FrameworkRequests::EnergyBillForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id, have_energy_bill:) }

  let(:framework_request) { create(:framework_request) }

  describe "validation" do
    describe "have_energy_bill" do
      let(:have_energy_bill) { nil }

      it { is_expected.to validate_presence_of(:have_energy_bill) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:have_energy_bill]).to eq ["Select whether you have a recent energy bill you can upload"]
        end
      end
    end
  end

  describe "#data" do
    context "when the user has an energy bill" do
      let(:have_energy_bill) { true }

      it "returns other energy fields nillified" do
        expect(form.data).to eq({ have_energy_bill: true, energy_alternative: nil })
      end
    end

    context "when the user has no energy bill" do
      let(:have_energy_bill) { false }

      it "returns the have_energy_bill value" do
        expect(form.data).to eq({ have_energy_bill: false })
      end
    end
  end

  describe "#have_energy_bill?" do
    context "when the user has an energy bill" do
      let(:have_energy_bill) { "true" }

      it "returns true" do
        expect(form.have_energy_bill?).to eq true
      end
    end

    context "when the user has no energy bill" do
      let(:have_energy_bill) { "false" }

      it "returns false" do
        expect(form.have_energy_bill?).to eq false
      end
    end
  end
end
