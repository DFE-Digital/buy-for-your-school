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
  end
end
