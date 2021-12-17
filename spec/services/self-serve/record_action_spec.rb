RSpec.describe RecordAction do
  describe "#call" do
    it "records the action in the database" do
      action = described_class.new(
        action: "begin_journey",
        journey_id: "12345678",
        user_id: "23456789",
      ).call

      expect(action.action).to eq "begin_journey"
    end

    context "when the action does not have additional parameters specified" do
      it "defaults undefined parameters to nil" do
        action = described_class.new(
          action: "begin_journey",
          journey_id: "12345678",
          user_id: "23456789",
        ).call

        expect(action.contentful_category_id).to be_nil
        expect(action.contentful_section_id).to be_nil
        expect(action.contentful_task_id).to be_nil
        expect(action.contentful_step_id).to be_nil
        expect(action.data).to be_nil
      end
    end

    context "when the action does has additional parameters specified" do
      it "correctly records additional parameters" do
        action = described_class.new(
          action: "begin_journey",
          journey_id: "12345678",
          user_id: "23456789",
          contentful_category_id: "34567890",
          contentful_section_id: "45678901",
          contentful_task_id: "56789012",
          contentful_step_id: "67890123",
          data: {},
        ).call

        expect(action.journey_id).to eq "12345678"
        expect(action.user_id).to eq "23456789"
        expect(action.contentful_category_id).to eq "34567890"
        expect(action.contentful_section_id).to eq "45678901"
        expect(action.contentful_task_id).to eq "56789012"
        expect(action.contentful_step_id).to eq "67890123"
        expect(action.data).to eq({})
      end
    end

    context "when the new action has an unexpected action type" do
      it "raises an error" do
        expect {
          described_class.new(
            action: "invalid_action",
            journey_id: "12345678",
            user_id: "23456789",
          ).call
        }.to raise_error RecordAction::UnexpectedActionType
      end

      it "raises a rollbar event" do
        expect(Rollbar).to receive(:warning)
          .with(
            "An attempt was made to log an action with an invalid type",
            action: "invalid_action",
            journey_id: "12345678",
            user_id: "23456789",
            contentful_category_id: nil,
            contentful_section_id: nil,
            contentful_task_id: nil,
            contentful_step_id: nil,
            data: nil,
            allowed_action_types: "begin_journey, view_journey, begin_task, view_task, begin_step, view_step, skip_step, save_answer, acknowledge_statement, update_answer, view_specification",
          ).and_call_original

        expect {
          described_class.new(
            action: "invalid_action",
            journey_id: "12345678",
            user_id: "23456789",
          ).call
        }.to raise_error RecordAction::UnexpectedActionType
      end
    end
  end
end
