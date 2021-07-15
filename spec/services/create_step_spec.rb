require "rails_helper"

RSpec.describe CreateStep do
  describe "#call" do
    context "when the new step is of type step" do
      it "creates a local copy of the new step" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/radio-question.json",
        )

        step = described_class.new(task: task, contentful_step: fake_entry, order: 0).call

        expect(step.title).to eq("Which service do you need?")
        expect(step.help_text).to eq("Tell us which service you need.")
        expect(step.contentful_id).to eq("radio-question")
        expect(step.contentful_model).to eq("question")
        expect(step.contentful_type).to eq("radios")
        expect(step.options).to eq([{ "value" => "Catering" }, { "value" => "Cleaning" }])
        expect(step.hidden).to eq(false)
        expect(step.additional_step_rules).to eq(nil)
        expect(step.order).to eq(0)
        expect(step.raw).to eq(
          "fields" => {
            "helpText" => "Tell us which service you need.",
            "extendedOptions" => [{ "value" => "Catering" }, { "value" => "Cleaning" }],
            "slug" => "/which-service",
            "title" => "Which service do you need?",
            "type" => "radios",
            "alwaysShowTheUser" => true,
          },
          "sys" => {
            "contentType" => {
              "sys" => {
                "id" => "question",
                "linkType" => "ContentType",
                "type" => "Link",
              },
            },
            "createdAt" => "2020-09-07T10:56:40.585Z",
            "environment" => {
              "sys" => {
                "id" => "master",
                "linkType" => "Environment",
                "type" => "Link",
              },
            },
            "id" => "radio-question",
            "locale" => "en-US",
            "revision" => 7,
            "space" => {
              "sys" => {
                "id" => "jspwts36h1os",
                "linkType" => "Space",
                "type" => "Link",
              },
            },
            "type" => "Entry",
            "updatedAt" => "2020-09-14T22:16:54.633Z",
          },
        )
      end
    end

    context "when the question is of type 'short_text'" do
      it "sets help_text and options to nil" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/short-text-question.json",
        )

        step = described_class.new(task: task, contentful_step: fake_entry, order: 0).call

        expect(step.options).to eq(nil)
      end

      it "replaces spaces with underscores" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/short-text-question.json",
        )

        step = described_class.new(task: task, contentful_step: fake_entry, order: 0).call

        expect(step.contentful_type).to eq("short_text")
      end
    end

    context "when the new entry has a 'body' field" do
      it "updates the step with the body" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/statement-step.json",
        )

        step, _answer = described_class.new(
          task: task, contentful_step: fake_entry, order: 0,
        ).call

        expect(step.body).to eq("#### Heading 4")
      end
    end

    context "when the new entry has a 'primaryCallToAction' field" do
      it "updates the step with the body" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/primary-button.json",
        )

        step, _answer = described_class.new(
          task: task, contentful_step: fake_entry, order: 0,
        ).call

        expect(step.primary_call_to_action_text).to eq("Go onwards!")
      end
    end

    context "when no 'primaryCallToAction' is provided" do
      it "default copy is used for the button" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/no-primary-button.json",
        )

        step, _answer = described_class.new(
          task: task, contentful_step: fake_entry, order: 0,
        ).call

        expect(step.primary_call_to_action_text).to eq(I18n.t("generic.button.next"))
      end
    end

    context "when no 'skipCallToAction' is provided" do
      it "default copy is used for the button" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/skippable-checkboxes-question.json",
        )

        step, _answer = described_class.new(
          task: task, contentful_step: fake_entry, order: 0,
        ).call

        expect(step.skip_call_to_action_text).to eq("None of the above")
      end
    end

    context "when no 'alwaysShowTheUser' is provided" do
      it "default hidden to true" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/no-hidden-field.json",
        )

        step, _answer = described_class.new(
          task: task, contentful_step: fake_entry, order: 0,
        ).call

        expect(step.hidden).to eq(false)
      end
    end

    context "when 'showAdditionalQuestion' is provided" do
      it "stores the rule as JSON" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/show-one-additional-question.json",
        )

        step, _answer = described_class.new(
          task: task, contentful_step: fake_entry, order: 0,
        ).call

        expect(step.additional_step_rules).to eql([
          {
            "required_answer" => "School expert",
            "question_identifiers" => %w[hidden-field-that-shows-an-additional-question],
          },
        ])
      end
    end

    context "when the new entry has an unexpected content model" do
      it "raises an error" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/unexpected-contentful-type.json",
        )

        expect { described_class.new(task: task, contentful_step: fake_entry, order: 0).call }
          .to raise_error(CreateStep::UnexpectedContentfulModel)
      end

      it "raises a rollbar event" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/unexpected-contentful-type.json",
        )

        expect(Rollbar).to receive(:warning)
          .with("An unexpected Contentful type was found",
                contentful_url: ENV["CONTENTFUL_URL"],
                contentful_space_id: ENV["CONTENTFUL_SPACE"],
                contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
                contentful_entry_id: "unexpected-contentful-type",
                content_model: "telepathy",
                step_type: "radios",
                allowed_content_models: CreateStep::ALLOWED_CONTENTFUL_MODELS.join(", "),
                allowed_step_types: CreateStep::ALLOWED_STEP_TYPES.join(", "))
          .and_call_original
        expect { described_class.new(task: task, contentful_step: fake_entry, order: 0).call }
          .to raise_error(CreateStep::UnexpectedContentfulModel)
      end
    end

    context "when the new step has an unexpected step type" do
      it "raises an error" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/unexpected-contentful-question-type.json",
        )

        expect { described_class.new(task: task, contentful_step: fake_entry, order: 0).call }
          .to raise_error(CreateStep::UnexpectedContentfulStepType)
      end

      it "raises a rollbar event" do
        category = create(:category, :catering)
        journey = create(:journey, category: category)
        section = create(:section, journey: journey)
        task = create(:task, section: section)

        fake_entry = fake_contentful_step(
          contentful_fixture_filename: "steps/unexpected-contentful-question-type.json",
        )

        expect(Rollbar).to receive(:warning)
          .with("An unexpected Contentful type was found",
                contentful_url: ENV["CONTENTFUL_URL"],
                contentful_space_id: ENV["CONTENTFUL_SPACE"],
                contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
                contentful_entry_id: "unexpected-contentful-question-type",
                content_model: "question",
                step_type: "telepathy",
                allowed_content_models: CreateStep::ALLOWED_CONTENTFUL_MODELS.join(", "),
                allowed_step_types: CreateStep::ALLOWED_STEP_TYPES.join(", "))
          .and_call_original
        expect { described_class.new(task: task, contentful_step: fake_entry, order: 0).call }
          .to raise_error(CreateStep::UnexpectedContentfulStepType)
      end
    end
  end
end
