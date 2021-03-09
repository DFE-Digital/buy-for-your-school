require "rails_helper"

RSpec.describe ToggleAdditionalSteps do
  describe "#call" do
    let(:journey) { create(:journey) }

    context "when the additional_step_rules field is nil" do
      it "returns nil" do
        step = build(:step)
        expect(described_class.new(step: step).call).to eq(nil)
      end
    end

    context "when the additional_step_rules exists" do
      context "when the answers match" do
        it "only shows the additional steps within the same journey" do
          step = create(:step,
            :radio,
            journey: journey,
            additional_step_rules: [{"required_answer" => "Red", "question_identifiers" => ["123"]}])
          create(:radio_answer, step: step, response: "Red")

          another_step_to_show = create(:step,
            :radio,
            journey: journey,
            contentful_id: "123",
            hidden: true)

          another_step_from_a_different_journey_to_keep_hidden = create(:step,
            :radio,
            contentful_id: "123",
            hidden: true)

          described_class.new(step: step).call

          expect(another_step_to_show.reload.hidden).to eq(false)
          expect(another_step_from_a_different_journey_to_keep_hidden.reload.hidden).to eq(true)
        end

        it "shows all additional_steps within the same journey" do
          step = create(:step,
            :radio,
            journey: journey,
            additional_step_rules: [{
              "required_answer" => "Red",
              "question_identifiers" => ["123", "456"]
            }])
          create(:radio_answer, step: step, response: "Red")

          first_additional_step_to_show = create(:step,
            :radio,
            journey: journey,
            contentful_id: "123",
            hidden: true)

          second_additional_step_to_show = create(:step,
            :radio,
            journey: journey,
            contentful_id: "456",
            hidden: true)

          another_step_from_a_different_journey_to_keep_hidden = create(:step,
            :radio,
            contentful_id: "123",
            hidden: true)

          described_class.new(step: step).call

          expect(first_additional_step_to_show.reload.hidden).to eq(false)
          expect(second_additional_step_to_show.reload.hidden).to eq(false)
          expect(another_step_from_a_different_journey_to_keep_hidden.reload.hidden).to eq(true)
        end

        context "when the required_answer matches the answer exactly" do
          it "updates the referenced step's hidden field to false" do
            step = create(:step,
              :radio,
              journey: journey,
              additional_step_rules: [{"required_answer" => "Red", "question_identifiers" => ["123"]}])
            create(:radio_answer, step: step, response: "Red")

            step_to_show = create(:step,
              :radio,
              journey: journey,
              contentful_id: "123",
              hidden: true)

            described_class.new(step: step).call

            expect(step_to_show.reload.hidden).to eq(false)
          end
        end

        context "when the required_answer has different case to the answer" do
          it "returns the updated step" do
            step = create(:step,
              :radio,
              journey: journey,
              additional_step_rules: [{"required_answer" => "RED", "question_identifiers" => ["123"]}])
            create(:radio_answer, step: step, response: "red")

            step_to_show = create(:step,
              :radio,
              journey: journey,
              contentful_id: "123",
              hidden: true)

            described_class.new(step: step).call

            expect(step_to_show.reload.hidden).to eq(false)
          end
        end

        context "when the referenced step also has an additional_step_rules rule" do
          it "shows both connected questions" do
            first_step = create(:step,
              :radio,
              journey: journey,
              additional_step_rules: [{"required_answer" => "Red", "question_identifiers" => ["123"]}],
              hidden: false)
            create(:radio_answer, step: first_step, response: "Red")

            second_step = create(:step,
              :radio,
              journey: journey,
              contentful_id: "123",
              additional_step_rules: [{"required_answer" => "Blue", "question_identifiers" => ["456"]}],
              hidden: true)
            create(:radio_answer, step: second_step, response: "Blue")

            third_step = create(:step,
              :radio,
              journey: journey,
              contentful_id: "456",
              hidden: true)

            described_class.new(step: first_step).call

            expect(second_step.reload.hidden).to eq(false)
            expect(third_step.reload.hidden).to eq(false)
          end
        end
      end

      context "when a branching question is shown based on more than on matching answer" do
        it "continues to show the next step (rather than hiding it again when it doesn't match the second rule)" do
          step = create(:step,
            :radio,
            journey: journey,
            additional_step_rules: [
              {"required_answer" => "red", "question_identifiers" => ["123"]},
              {"required_answer" => "blue", "question_identifiers" => ["123"]}
            ])
          create(:radio_answer, step: step, response: "red")

          step_to_show = create(:step,
            :radio,
            journey: journey,
            contentful_id: "123",
            hidden: true)

          described_class.new(step: step).call

          expect(step_to_show.reload.hidden).to eq(false)
        end
      end

      context "when the answers DO NOT match" do
        it "updates the referenced step's hidden field to true" do
          step = create(:step,
            :radio,
            journey: journey,
            additional_step_rules: [{"required_answer" => "Red", "question_identifiers" => ["123"]}])
          create(:radio_answer, step: step, response: "Blue")

          step_to_show = create(:step,
            :radio,
            journey: journey,
            contentful_id: "123",
            hidden: false)

          described_class.new(step: step).call

          expect(step_to_show.reload.hidden).to eq(true)
        end

        it "hides all additional_steps within the same journey" do
          step = create(:step,
            :radio,
            journey: journey,
            additional_step_rules: [{
              "required_answer" => "Red",
              "question_identifiers" => ["123", "456"]
            }])
          create(:radio_answer, step: step, response: "NOT Red")

          first_additional_step_to_hide = create(:step,
            :radio,
            journey: journey,
            contentful_id: "123",
            hidden: false)

          second_additional_step_to_hide = create(:step,
            :radio,
            journey: journey,
            contentful_id: "456",
            hidden: false)

          another_step_from_a_different_journey_to_keep_hidden = create(:step,
            :radio,
            contentful_id: "123",
            hidden: true)

          described_class.new(step: step).call

          expect(first_additional_step_to_hide.reload.hidden).to eq(true)
          expect(second_additional_step_to_hide.reload.hidden).to eq(true)
          expect(another_step_from_a_different_journey_to_keep_hidden.reload.hidden).to eq(true)
        end

        context "when the required_answer has different case to the answer" do
          it "does not hide the step" do
            step = create(:step,
              :radio,
              journey: journey,
              additional_step_rules: [{"required_answer" => "RED", "question_identifiers" => ["123"]}])
            create(:radio_answer, step: step, response: "red")

            step_to_show = create(:step,
              :radio,
              journey: journey,
              contentful_id: "123",
              hidden: false)

            described_class.new(step: step).call

            expect(step_to_show.reload.hidden).to eq(false)
          end
        end

        context "when the referenced step also has an additional_step_rules rule" do
          it "hides both connected questions" do
            first_step = create(:step,
              :radio,
              journey: journey,
              additional_step_rules: [{"required_answer" => "Red", "question_identifiers" => ["123"]}],
              hidden: false)
            create(:radio_answer, step: first_step, response: "Changed from red")

            second_step = create(:step,
              :radio,
              journey: journey,
              contentful_id: "123",
              additional_step_rules: [{"required_answer" => "Blue", "question_identifiers" => ["456"]}],
              hidden: false)
            create(:radio_answer, step: second_step, response: "Blue")

            third_step = create(:step,
              :radio,
              journey: journey,
              contentful_id: "456",
              hidden: false)

            described_class.new(step: first_step).call

            expect(second_step.reload.hidden).to eq(true)
            expect(third_step.reload.hidden).to eq(true)
          end
        end
      end

      context "when the answer response is an array" do
        it "checks for a match against all answers" do
          step = create(:step,
            :checkbox_answers,
            journey: journey,
            additional_step_rules: [{"required_answer" => "Red", "question_identifiers" => ["123"]}])
          create(:checkbox_answers, step: step, response: ["Blue", "Red"])

          step_to_show = create(:step,
            :radio,
            journey: journey,
            contentful_id: "123",
            hidden: true)

          described_class.new(step: step).call

          expect(step_to_show.reload.hidden).to eq(false)
        end
      end
    end
  end
end
