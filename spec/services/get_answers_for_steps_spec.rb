require "rails_helper"

RSpec.shared_examples "returns the answer in a hash" do |factory_name, presenter, response|
  it "returns the response for a #{factory_name} in the result" do
    answer = create(factory_name, response: response)
    result = described_class.new(visible_steps: [answer.step]).call
    expect(result).to include(
      {
        "answer_#{answer.step.contentful_id}" => presenter.new(answer).to_param
      }
    )
  end
end

RSpec.describe GetAnswersForSteps do
  describe "#call" do
    it "only returns answers for the given journey" do
      relevant_answer = create(:short_text_answer, response: "Red")
      irrelevant_answer = create(:short_text_answer, response: "Blue")

      result = described_class.new(visible_steps: [relevant_answer.step]).call

      expect(result).to be_a(Hash)
      expect(result).to include(
        {"answer_#{relevant_answer.step.contentful_id}" => "Red"}
      )
      expect(result).not_to include(
        {"answer_#{irrelevant_answer.step.contentful_id}" => "Blue"}
      )
    end

    context "when the answer is of type short_text_answer" do
      it_behaves_like "returns the answer in a hash", :short_text_answer, ShortTextAnswerPresenter, "Red"
    end

    context "when the answer is of type long_text_answer" do
      it_behaves_like "returns the answer in a hash", :long_text_answer, LongTextAnswerPresenter, "<p>Red Blue Yellow</p>"
    end

    context "when the answer is of type single_date_answer" do
      it_behaves_like "returns the answer in a hash", :single_date_answer, SingleDateAnswerPresenter, "12 Jan 2020"
    end

    context "when the answer is of type radio_answer" do
      it_behaves_like "returns the answer in a hash", :radio_answer, RadioAnswerPresenter, "Catering"

      context "when the answer has further_information" do
        it "also includes an extended_answer hash in the response" do
          answer = create(:radio_answer,
            response: "yes please",
            further_information: "More yes info")
          result = described_class.new(visible_steps: [answer.step]).call
          expect(result).to include(
            {"answer_#{answer.step.contentful_id}" => "Yes please"}
          )
          expect(result).to include(
            {
              "extended_answer_#{answer.step.contentful_id}" => [
                {
                  "response" => "Yes please",
                  "further_information" => "More yes info"
                }
              ]
            }
          )
        end
      end
    end

    context "when the answer is of type checkbox_answers" do
      it "returns the answer information in a hash" do
        answer = create(:checkbox_answers,
          response: ["Foo", "Bar"],
          skipped: false,
          further_information: {"foo_further_information" => "More yes info"})

        result = described_class.new(visible_steps: [answer.step]).call
        assertion = {
          "answer_#{answer.step.contentful_id}" => {
            response: ["Foo", "Bar"],
            concatenated_response: "Foo, Bar",
            skipped: false,
            selected_answers: [
              {
                machine_value: :foo,
                human_value: "Foo",
                further_information: "More yes info"
              },
              {
                machine_value: :bar,
                human_value: "Bar",
                further_information: nil
              }
            ]
          }
        }

        expect(result).to match(a_hash_including(assertion))
      end

      context "when there is no further_information at all" do
        it "returns no further_information in selected_answers" do
          answer = create(:checkbox_answers,
            response: ["Foo"],
            skipped: false,
            further_information: nil)

          result = described_class.new(visible_steps: [answer.step]).call
          assertion = {
            "answer_#{answer.step.contentful_id}" => {
              response: ["Foo"],
              concatenated_response: "Foo",
              skipped: false,
              selected_answers: [
                {
                  machine_value: :foo,
                  human_value: "Foo",
                  further_information: nil
                }
              ]
            }
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
        answerable_step = create(:step, :radio, journey: journey)
        _answer = create(:radio_answer, step: answerable_step)
        unanswerable_step = create(:step, :radio, journey: journey)

        result = described_class.new(visible_steps: [answerable_step]).call

        expect(result.keys).to include("answer_#{answerable_step.contentful_id}")
        expect(result.keys).not_to include("answer_#{unanswerable_step.contentful_id}")
      end
    end
  end
end
