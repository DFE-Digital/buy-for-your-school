RSpec.describe SupportFormWizard, type: :model do
  let(:current_form_step) { described_class.new }
  let(:journey) { create(:journey) }
  let(:category) { create(:category) }
  let(:user) { create(:user) }
  let(:message) { "My support message" }

  context "when current step # 1" do
    let(:current_form_step) { SupportFormWizard::Step1.new(step: 1) }

    describe "#save" do
      context "with a journey" do
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

  context "when current step # 2" do
    let(:current_form_step) { SupportFormWizard::Step2.new(step: 2, journey_id: journey.id) }

    describe "#save" do
      context "with a category" do
        let(:current_form_step) { SupportFormWizard::Step2.new(step: 2, journey_id: journey.id, category_id: category.id) }

        it "returns valid? true" do
          expect(current_form_step.valid?).to eq true
        end

        it "returns next step count on save" do
          expect(current_form_step.save).to eq 3
        end
      end

      context "without a category" do
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
        expect(current_form_step.next_step).to eq 3
      end
    end

    describe "#last_step" do
      it "returns false" do
        expect(current_form_step.last_step?).to eq false
      end
    end
  end

  context "when last step" do
    let(:current_form_step) { SupportFormWizard::Step3.new(step: 3, journey_id: journey.id, category_id: category.id) }

    describe "#save" do
      context "without a user" do
        let(:current_form_step) do
          SupportFormWizard::Step3.new(
            step: 3, journey_id: journey.id, category_id: category.id, message: message, user: nil
          )
        end

        it "returns valid? false" do
          expect(current_form_step.valid?).to eq false
        end
      end

      context "without a message" do
        let(:current_form_step) do
          SupportFormWizard::Step3.new(
            step: 3, journey_id: journey.id, category_id: category.id, user: user,
          )
        end

        it "returns valid? false" do
          expect(current_form_step.valid?).to eq false
        end
      end

      context "with a user" do
        let(:current_form_step) do
          SupportFormWizard::Step3.new(
            step: 3, journey_id: journey.id, category_id: category.id, message: message, user: user,
          )
        end

        it "returns valid? false" do
          expect(current_form_step.valid?).to eq true
        end
      end

      context "with a message" do
        let(:current_form_step) do
          SupportFormWizard::Step3.new(
            step: 3, journey_id: journey.id, category_id: category.id, message: message, user: user,
            )
        end

        it "returns valid? true" do
          expect(current_form_step.valid?).to eq true
        end
      end
    end

    describe "#next_step" do
      it "returns the next step number" do
        expect(current_form_step.next_step).to eq 4
      end
    end

    describe "#last_step" do
      it "returns false" do
        expect(current_form_step.last_step?).to eq true
      end
    end
  end
end
