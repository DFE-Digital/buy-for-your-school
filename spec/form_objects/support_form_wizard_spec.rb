RSpec.describe SupportFormWizard, type: :model do
  let(:current_form_step) { described_class.new }
  let(:phone_number) { "0151 000 0000" }
  let(:journey) { create(:journey) }
  let(:category) { create(:category) }
  let(:user) { create(:user) }
  let(:message) { "My support message" }

  context "when current step # 1" do
    let(:current_form_step) { SupportFormWizard::Step1.new(step: 1) }

    describe "#save" do
      context "with a phone number" do
        let(:current_form_step) { SupportFormWizard::Step1.new(step: 1, phone_number: phone_number) }

        it "is valid" do
          expect(current_form_step.valid?).to eq true
        end

        it "increments the step counter" do
          expect(current_form_step.save).to eq 2
        end
      end

      context "without a phone number" do
        it "is not valid" do
          expect(current_form_step.valid?).to eq false
        end

        it "does not save" do
          expect(current_form_step.save).to eq false
        end
      end
    end

    describe "#next_step" do
      it "increments the step counter" do
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
    let(:current_form_step) { SupportFormWizard::Step2.new(step: 2, phone_number: phone_number) }

    describe "#save" do
      context "with a journey" do
        let(:current_form_step) { SupportFormWizard::Step2.new(step: 2, phone_number: phone_number, journey_id: journey.id) }

        it "is valid" do
          expect(current_form_step.valid?).to eq true
        end

        it "increments the step counter" do
          expect(current_form_step.save).to eq 3
        end
      end

      context "without a journey" do
        it "is not valid" do
          expect(current_form_step.valid?).to eq false
        end

        it "does not save" do
          expect(current_form_step.save).to eq false
        end
      end
    end

    describe "#next_step" do
      it "increments the step counter" do
        expect(current_form_step.next_step).to eq 3
      end
    end

    describe "#last_step" do
      it "returns false" do
        expect(current_form_step.last_step?).to eq false
      end
    end
  end

  context "when current step # 3" do
    let(:current_form_step) { SupportFormWizard::Step3.new(step: 3, phone_number: phone_number, journey_id: journey.id) }

    describe "#save" do
      context "with a category" do
        let(:current_form_step) { SupportFormWizard::Step3.new(step: 3, phone_number: phone_number, journey_id: journey.id, category_id: category.id) }

        it "is valid" do
          expect(current_form_step.valid?).to eq true
        end

        it "increments the step counter" do
          expect(current_form_step.save).to eq 4
        end
      end

      context "without a category" do
        it "is not valid" do
          expect(current_form_step.valid?).to eq false
        end

        it "does not save" do
          expect(current_form_step.save).to eq false
        end
      end
    end

    describe "#next_step" do
      it "increments the step counter" do
        expect(current_form_step.next_step).to eq 4
      end
    end

    describe "#last_step" do
      it "returns false" do
        expect(current_form_step.last_step?).to eq false
      end
    end
  end

  context "when last step" do
    let(:current_form_step) do
      SupportFormWizard::Step4.new(
        step: 4, phone_number: phone_number, journey_id: journey.id, category_id: category.id, message: message, user: user,
      )

      describe "#save" do
        context "without a user" do
          let(:current_form_step) do
            SupportFormWizard::Step4.new(
              step: 4, phone_number: phone_number, journey_id: journey.id, category_id: category.id, message: message, user: nil,
            )
          end

          it "is not valid" do
            expect(current_form_step.valid?).to eq false
          end
        end

        context "without a message" do
          let(:current_form_step) do
            SupportFormWizard::Step4.new(
              step: 3, phone_number: phone_number, journey_id: journey.id, category_id: category.id, user: user,
            )
          end

          it "is not valid" do
            expect(current_form_step.valid?).to eq false
          end
        end

        context "with a user and message" do
          it "is valid" do
            expect(current_form_step.valid?).to eq true
          end
        end
      end

      describe "#next_step" do
        it "increments the step counter" do
          expect(current_form_step.next_step).to eq 5
        end
      end

      describe "#last_step" do
        it "returns false" do
          expect(current_form_step.last_step?).to eq true
        end
      end
    end
  end
end
