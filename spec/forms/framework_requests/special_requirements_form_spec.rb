describe FrameworkRequests::SpecialRequirementsForm, type: :model do
  subject(:form) { described_class.new(id: framework_request.id) }

  let(:framework_request) { create(:framework_request, special_requirements: nil) }

  describe "validation" do
    describe "special_requirements_choice" do
      it { is_expected.to validate_presence_of(:special_requirements_choice) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:special_requirements_choice]).to eq ["Select whether you want to tell us about any special requirements"]
        end
      end
    end

    describe "special_requirements" do
      context "when special_requirements_choice? is true" do
        before { allow(form).to receive(:special_requirements_choice?).and_return(true) }

        it { is_expected.to validate_presence_of(:special_requirements) }
      end

      context "when special_requirements_choice is false" do
        before { allow(form).to receive(:special_requirements_choice?).and_return(false) }

        it { is_expected.not_to validate_presence_of(:special_requirements) }
      end

      context "when validation fails" do
        before { allow(form).to receive(:special_requirements_choice?).and_return(true) }

        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:special_requirements]).to eq ["Enter what your requirements are"]
        end
      end
    end
  end

  describe "#save!" do
    context "when special_requirements_choice is 'no'" do
      subject(:form) { described_class.new(id: framework_request.id, special_requirements_choice: "no") }

      it "saves special_requirements as nil" do
        form.save!

        expect(framework_request.special_requirements).to be nil
      end
    end

    context "when special_requirements_choice is 'yes'" do
      subject(:form) { described_class.new(id: framework_request.id, special_requirements_choice: "yes", special_requirements: "test requirements") }

      it "saves special_requirements" do
        form.save!

        expect(framework_request.reload.special_requirements).to eq "test requirements"
      end
    end
  end

  describe "#special_requirements_choice?" do
    context "when special_requirements_choice is 'yes " do
      subject(:form) { described_class.new(id: framework_request.id, special_requirements_choice: "yes") }

      it "returns true" do
        expect(form.special_requirements_choice?).to be true
      end
    end

    context "when special_requirements_choice is 'no " do
      subject(:form) { described_class.new(id: framework_request.id, special_requirements_choice: "no") }

      it "returns false" do
        expect(form.special_requirements_choice?).to be false
      end
    end
  end
end
