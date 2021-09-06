RSpec.describe SupportFormWizard, type: :model do
  let(:current_form_step) { described_class.new }

  context "when current step # 1" do
    let(:current_form_step) { SupportFormWizard::Step1.new(step: 1) }
    let(:journey) { create(:journey) }

    describe "#save" do
      context "with a journey id" do
        let(:current_form_step) { SupportFormWizard::Step1.new(step: 1, journey_id: journey.id) }

        it "returns valid? true" do
          expect(current_form_step.valid?).to eq true
        end

        it "returns next step count on save" do
          expect(current_form_step.save).to eq 2
        end
      end

      context "without a journey" do
        it "returns valid? false" do
          expect(current_form_step.valid?).to eq false
        end

        it "returns false on save" do
          expect(current_form_step.save).to eq false
        end
      end
    end

    describe "#next_step" do
      it "returns the next step number" do
        expect(current_form_step.next_step).to eq 2
      end
    end

    describe "#last_step" do
      it "returns false" do
        expect(current_form_step.last_step?).to eq false
      end
    end
  end


end
