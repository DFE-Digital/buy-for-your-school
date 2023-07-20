RSpec.describe CreateStep do
  describe "#call" do
    subject(:service) do
      described_class.new(
        task:,
        contentful_step:,
        order: 0,
      )
    end

    let(:category) { create(:category, :catering) }
    let(:journey) { create(:journey, category:) }
    let(:section) { create(:section, journey:) }
    let(:task) { create(:task, section:) }

    let(:contentful_step) do
      fake_contentful_step(contentful_fixture_filename: "steps/#{fixture}.json")
    end

    context "when the new step is of type step" do
      let(:fixture) { "radio-question" }

      it "creates a local copy of the new step" do
        step = service.call

        expect(step.title).to eq "Which service do you need?"
        expect(step.help_text).to eq "Tell us which service you need."
        expect(step.contentful_id).to eq "radio-question"
        expect(step.contentful_model).to eq "question"
        expect(step.contentful_type).to eq "radios"
        expect(step.options).to eq([{ "value" => "Catering" }, { "value" => "Cleaning" }])
        expect(step.hidden).to be false
        expect(step.additional_step_rules).to be_nil
        expect(step.order).to eq 0
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
      let(:fixture) { "short-text-question" }

      it "sets help_text and options to nil" do
        step = service.call

        expect(step.options).to be_nil
      end

      it "replaces spaces with underscores" do
        step = service.call

        expect(step.contentful_type).to eq "short_text"
      end
    end

    context "when the new entry has a 'body' field" do
      let(:fixture) { "statement-step" }

      it "updates the step with the body" do
        step = service.call

        expect(step.body).to eq "#### Heading 4"
      end
    end

    context "when the new entry has a 'primaryCallToAction' field" do
      let(:fixture) { "primary-button" }

      it "updates the step with the body" do
        step = service.call

        expect(step.primary_call_to_action_text).to eq "Go onwards!"
      end
    end

    context "when no 'primaryCallToAction' is provided" do
      let(:fixture) { "no-primary-button" }

      it "default copy is used for the button" do
        step = service.call

        expect(step.primary_call_to_action_text).to eq "Continue"
      end
    end

    context "when no 'skipCallToAction' is provided" do
      let(:fixture) { "skippable-checkboxes-question" }

      it "default copy is used for the button" do
        step = service.call

        expect(step.skip_call_to_action_text).to eq "None of the above"
      end
    end

    context "when no 'alwaysShowTheUser' is provided" do
      let(:fixture) { "no-hidden-field" }

      it "default hidden to true" do
        step = service.call

        expect(step.hidden).to be false
      end
    end

    context "when 'showAdditionalQuestion' is provided" do
      let(:fixture) { "show-one-additional-question" }

      it "stores the rule as JSON" do
        step = service.call

        expect(step.additional_step_rules).to eql([
          {
            "required_answer" => "School expert",
            "question_identifiers" => %w[hidden-field-that-shows-an-additional-question],
          },
        ])
      end
    end

    context "when the new entry has an unexpected content model" do
      let(:fixture) { "unexpected-contentful-type" }

      it "raises an error" do
        expect { service.call }.to raise_error(CreateStep::UnexpectedContentfulModel)
      end
    end

    context "when the new step has an unexpected step type" do
      let(:fixture) { "unexpected-contentful-question-type" }

      it "raises an error" do
        expect { service.call }.to raise_error(CreateStep::UnexpectedContentfulStepType)
      end
    end

    context "when the step has validation criteria" do
      let(:fixture) { "single-date-in-past-question" }

      it "creates a step with the criteria" do
        step = service.call

        expect(step.criteria).to eq({
          "message" => "Are you a time traveller!",
          "lower" => "1947-10-13 12:34",
          "upper" => "2000-01-01 00:01)",
        })
      end
    end
  end
end
