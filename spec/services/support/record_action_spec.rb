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
        }.to raise_error Dry::Types::ConstraintError
      end
    end
  end
end
