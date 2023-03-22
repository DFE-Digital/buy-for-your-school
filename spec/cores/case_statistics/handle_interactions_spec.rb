require "rails_helper"

describe CaseStatistics::HandleInteractions do
  subject(:handler) { described_class.new }

  describe "#interaction_created" do
    let(:support_case) { create(:support_case) }

    it "creates an activity log item for the interaction" do
      payload = { support_case_id: support_case.id, event_type: "phone_call" }

      expect { handler.interaction_created(payload) }.to change(Support::ActivityLogItem, :count).from(0).to(1)
      item = Support::ActivityLogItem.last
      expect(item.support_case_id).to eq(support_case.id)
      expect(item.action).to eq("add_interaction")
      expect(item.data["event_type"]).to eq("phone_call")
    end
  end
end
