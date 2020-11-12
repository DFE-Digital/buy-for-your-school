require "rails_helper"

RSpec.describe CreatePlanningQuestion do
  describe "#call" do
    context "when the new question is of type question" do
      it "creates a local copy of the new question" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
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
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "has-next-question-example.json"
        )

        _question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(plan.next_entry_id).to eql("5lYcZs1ootDrOnk09LDLZg")
      end
    end

    context "when the question is of type 'radios'" do
      it "returns a fresh RadioAnswer object" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "radio-question-example.json"
        )

        _question, answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(answer).to be_kind_of(RadioAnswer)
        expect(answer.response).to eql(nil)
      end
    end

    context "when the question is of type 'short_text'" do
      it "returns a fresh ShortTextAnswer object" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "short-text-question-example.json"
        )

        _question, answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(answer).to be_kind_of(ShortTextAnswer)
        expect(answer.response).to eql(nil)
      end

      it "sets help_text and options to nil" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "short-text-question-example.json"
        )

        question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(question.help_text).to eq(nil)
        expect(question.options).to eq(nil)
      end

      it "replaces spaces with underscores" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "short-text-question-example.json"
        )

        question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(question.contentful_type).to eq("short_text")
      end
    end

    context "when the new question does not have a following question" do
      it "updates the plan by setting the next_entry_id to nil" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "radio-question-example.json"
        )

        _question, _answer = described_class.new(plan: plan, contentful_entry: fake_entry).call

        expect(plan.next_entry_id).to eql(nil)
      end
    end

    context "when the new entry has an unexpected content model" do
      it "raises an error" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "an-unexpected-model-example.json"
        )

        expect { described_class.new(plan: plan, contentful_entry: fake_entry).call }
          .to raise_error(CreatePlanningQuestion::UnexpectedContentfulModel)
      end

      it "raises a rollbar event" do
        plan = create(:plan, :catering)

        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "an-unexpected-model-example.json"
        )

        expect(Rollbar).to receive(:warning)
          .with("An unexpected Contentful type was found",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "6EKsv389ETYcQql3htK3Z2",
            content_model: "unmanagedPage",
            question_type: "radios",
            allowed_content_models: CreatePlanningQuestion::ALLOWED_CONTENTFUL_MODELS.join(", "),
            allowed_question_types: CreatePlanningQuestion::ALLOWED_CONTENTFUL_QUESTION_TYPES.join(", "))
          .and_call_original
        expect { described_class.new(plan: plan, contentful_entry: fake_entry).call }
          .to raise_error(CreatePlanningQuestion::UnexpectedContentfulModel)
      end
    end

    context "when the new question has an unexpected type" do
      it "raises an error" do
        plan = create(:plan, :catering)
        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "an-unexpected-question-type-example.json"
        )

        expect { described_class.new(plan: plan, contentful_entry: fake_entry).call }
          .to raise_error(CreatePlanningQuestion::UnexpectedContentfulQuestionType)
      end

      it "raises a rollbar event" do
        plan = create(:plan, :catering)

        fake_entry = fake_contentful_question_entry(
          contentful_fixture_filename: "an-unexpected-question-type-example.json"
        )

        expect(Rollbar).to receive(:warning)
          .with("An unexpected Contentful type was found",
            contentful_url: ENV["CONTENTFUL_URL"],
            contentful_space_id: ENV["CONTENTFUL_SPACE"],
            contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
            contentful_entry_id: "8as7df68uhasdnuasdf",
            content_model: "question",
            question_type: "telepathy",
            allowed_content_models: CreatePlanningQuestion::ALLOWED_CONTENTFUL_MODELS.join(", "),
            allowed_question_types: CreatePlanningQuestion::ALLOWED_CONTENTFUL_QUESTION_TYPES.join(", "))
          .and_call_original
        expect { described_class.new(plan: plan, contentful_entry: fake_entry).call }
          .to raise_error(CreatePlanningQuestion::UnexpectedContentfulQuestionType)
      end
    end
  end
end
