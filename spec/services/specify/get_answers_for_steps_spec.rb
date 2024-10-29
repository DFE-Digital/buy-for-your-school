require "rails_helper"

RSpec.describe GetAnswersForSteps do
  describe "#call" do
    it "only returns answers for the given journey" do
      relevant_answer = create(:short_text_answer, response: "Red")
      irrelevant_answer = create(:short_text_answer, response: "Blue")

      result = described_class.new(visible_steps: [relevant_answer.step]).call

      expect(result).to be_a(Hash)
      expect(result).to include(
        { "answer_#{relevant_answer.step.contentful_id}" => { response: "Red" } },
      )
      expect(result).not_to include(
        { "answer_#{irrelevant_answer.step.contentful_id}" => { response: "Blue" } },
      )
    end

    it "returns a hash with_indifferent_access so Liquid can use the string syntax for access" do
      answer = create(:short_text_answer, response: "Red")
      result = described_class.new(visible_steps: [answer.step]).call
      expect(result).to include({ "answer_#{answer.step.contentful_id}" => { "response" => "Red" } })
    end

    context "when the answer is of type short_text_answer" do
      it "returns the answer information in a hash" do
        answer = create(:short_text_answer, response: "Red")
        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: "Red",
          },
        }

        expect(result).to match(a_hash_including(assertion))
      end
    end

    context "when the answer is of type long_text_answer" do
      it "returns the answer information in a hash" do
        answer = create(:long_text_answer, response: "Red\r\n\r\n\r\nBlue")
        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: "Red\r\n\r\n\r\nBlue",
          },
        }

        expect(result).to match(a_hash_including(assertion))
      end
    end

    context "when the answer is of type single_date_answer" do
      it "returns the answer information in a hash" do
        answer = create(:single_date_answer, response: Date.new(2000, 12, 30))

        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: "30 Dec 2000",
          },
        }

        expect(result).to match(a_hash_including(assertion))
      end
    end

    context "when the answer is of type radio_answer" do
      it "returns the answer information in a hash" do
        answer = create(:radio_answer,
                        response: "Yes please",
                        further_information: { yes_please_further_information: "More yes info" })

        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: "Yes please",
            further_information: "More yes info",
          },
        }

        expect(result).to match(a_hash_including(assertion))
      end
    end

    context "when the answer is of type currency_answer" do
      it "returns the answer information in a hash" do
        answer = create(:currency_answer, response: 100.01)

        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: "£100.01",
          },
        }

        expect(result).to match(a_hash_including(assertion))
      end
    end

    context "when the answer is of type number_answer" do
      it "returns the answer information in a hash" do
        answer = create(:number_answer, response: 2)

        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: "2",
          },
        }

        expect(result).to match(a_hash_including(assertion))
      end
    end

    context "when the answer is of type checkbox_answers" do
      it "returns the answer information in a hash" do
        answer = create(:checkbox_answers,
                        response: %w[Foo Bar],
                        skipped: false,
                        further_information: { "foo_further_information" => "More yes info" })

        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: %w[Foo Bar],
            concatenated_response: "Foo, Bar",
            skipped: false,
            selected_answers: [
              {
                machine_value: :foo,
                human_value: "Foo",
                further_information: "More yes info",
              },
              {
                machine_value: :bar,
                human_value: "Bar",
                further_information: nil,
              },
            ],
          },
        }

        expect(result).to match(a_hash_including(assertion))
      end

      context "when there is no further_information at all" do
        it "returns no further_information in selected_answers" do
          answer = create(:checkbox_answers,
                          response: %w[Foo],
                          skipped: false,
                          further_information: nil)

          result = described_class.new(visible_steps: [answer.step]).call
          assertion = {
            "answer_#{answer.step.contentful_id}" => {
              response: %w[Foo],
              concatenated_response: "Foo",
              skipped: false,
              selected_answers: [
                {
                  machine_value: :foo,
                  human_value: "Foo",
                  further_information: nil,
                },
              ],
            },
          }

          expect(result).to match(a_hash_including(assertion))
        end
      end
    end

    context "when a step does not have an answer" do
      it "the step does not have an answer in the result" do
        unanswered_step = create(:step, :radio)
        result = described_class.new(visible_steps: [unanswered_step]).call
        expect(result.keys).not_to include("answer_#{unanswered_step.contentful_id}")
      end
    end

    context "when the type of answer is unknown" do
      it "raises an unexpected error" do
        allow_any_instance_of(Step).to receive(:answer)
          .and_return(double(class: double(name: "UnknownClass")))
        step = create(:step, :radio)
        expect {
          described_class.new(visible_steps: [step]).call
        }.to raise_error(GetAnswersForSteps::UnexpectedAnswer)
      end
    end

    context "when there is no answer for a step" do
      it "does not try to prepare that answer in the result" do
        journey = create(:journey)
        section = create(:section, journey:)
        task = create(:task, section:)
        answerable_step = create(:step, :radio, task:)
        _answer = create(:radio_answer, step: answerable_step)
        unanswerable_step = create(:step, :radio, task:)

        result = described_class.new(visible_steps: [answerable_step]).call

        expect(result.keys).to include("answer_#{answerable_step.contentful_id}")
        expect(result.keys).not_to include("answer_#{unanswerable_step.contentful_id}")
      end
    end

    context "when the answer includes script characters" do
      it "removes them from the answer that is then saved" do
        answer = create(:short_text_answer,
                        response: "<script>alert('problem');</script>A little text")

        expect_any_instance_of(StringSanitiser).to receive(:call).and_call_original

        result = described_class.new(visible_steps: [answer.step]).call

        expect(result["answer_#{answer.step.contentful_id}"])
          .to eql({ "response" => "alert('problem');A little text" })
      end
    end
  end
end
