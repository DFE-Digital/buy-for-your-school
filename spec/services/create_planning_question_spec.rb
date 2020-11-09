require "rails_helper"

RSpec.describe CreatePlanningQuestion do
  describe "#call" do
    context "when the new question is of type question" do
      it "creates a local copy of the new question" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_radio_question_entry(
          contentful_fixture_filename: "radio-question-example.json"
        )

        question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(question.title).to eq("Which service do you need?")
        expect(question.help_text).to eq("Tell us which service you need.")
        expect(question.contentful_type).to eq("radios")
        expect(question.options).to eq(["Catering", "Cleaning"])
        expect(question.raw).to eq(fake_entry.raw)
      end

      it "updates the plan with a new next_entry_id" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_radio_question_entry(
          contentful_fixture_filename: "has-next-question-example.json"
        )

        _question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(plan.next_entry_id).to eql("5lYcZs1ootDrOnk09LDLZg")
      end

      it "returns a fresh answer object" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_radio_question_entry(
          contentful_fixture_filename: "radio-question-example.json"
        )

        _question, answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(answer).to be_kind_of(Answer)
        expect(answer.response).to eql(nil)
      end
    end

    context "when the question is of type short_text" do
      it "sets help_text and options to nil" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_radio_question_entry(
          contentful_fixture_filename: "short-text-question-example.json"
        )

        question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(question.help_text).to eq(nil)
        expect(question.options).to eq(nil)
      end
    end

    context "when the new question does not have a following question" do
      it "updates the plan by setting the next_entry_id to nil" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_radio_question_entry(
          contentful_fixture_filename: "radio-question-example.json"
        )

        _question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(plan.next_entry_id).to eql(nil)
      end
    end

    context "when the new question has an unexpected content type" do
      it "raises an error" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_radio_question_entry(
          contentful_fixture_filename: "a-non-question-example.json"
        )

        expect { described_class.new(plan: plan, contentful_entry: fake_entry).call }
          .to raise_error(CreatePlanningQuestion::UnexpectedContentType)
      end

      it "raises a rollbar event" do
        plan = create(:plan, :catering)

        fake_entry = fake_contentful_radio_question_entry(
          contentful_fixture_filename: "a-non-question-example.json"
        )

        expect(Rollbar).to receive(:warning)
          .with("An unexpected Entry type was found instead of a question",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "6EKsv389ETYcQql3htK3Z2",
            content_type: "unmanagedPage",
            allowed_content_types: CreatePlanningQuestion::ALLOWED_CONTENTFUL_CONTENT_TYPES.join(", "))
          .and_call_original
        expect { described_class.new(plan: plan, contentful_entry: fake_entry).call }
          .to raise_error(CreatePlanningQuestion::UnexpectedContentType)
      end
    end
  end
end
