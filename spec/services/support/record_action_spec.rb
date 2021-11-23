RSpec.describe Support::RecordAction do
  let(:support_case) { create(:support_case) }

  describe "#call" do
    it "records the action in the database" do
      action = described_class.new(
        action: "open_case",
        support_case_id: support_case.id,
      ).call

      expect(action.action).to eq "open_case"
    end

    context "when the action does has additional parameters specified" do
      it "correctly records additional parameters" do
        action = described_class.new(
          action: "add_interaction",
          support_case_id: support_case.id,
          data: { event_type: "phone" },
        ).call

        expect(action.support_case_id).to eq support_case.id
        expect(action.data).to eq({ "event_type" => "phone" })
      end
    end

    context "when the new action has an unexpected action type" do
      it "raises an error" do
        expect {
          described_class.new(
            action: "invalid_action",
            support_case_id: support_case.id,
          ).call
        }.to raise_error Support::RecordAction::UnexpectedActionType
      end

      it "raises a rollbar event" do
        expect(Rollbar).to receive(:warning)
          .with(
            "An attempt was made to log a support case action with an invalid type",
            action: "invalid_action",
            support_case_id: "12345678",
            data: {},
            allowed_action_types: "open_case, add_interaction, change_category, change_service_level, change_state, resolve_case, close_case",
          ).and_call_original

        expect {
          described_class.new(
            action: "invalid_action",
            support_case_id: "12345678",
          ).call
        }.to raise_error Support::RecordAction::UnexpectedActionType
      end
    end
  end
end
