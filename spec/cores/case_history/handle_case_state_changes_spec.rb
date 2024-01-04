require "rails_helper"

describe CaseHistory::HandleCaseStateChanges do
  subject(:handler) { described_class.new }

  before { define_basic_procurement_stages }

  describe "#case_opened" do
    let(:support_case_id) { create(:support_case).id }
    let(:agent_id) { create(:support_agent).id }
    let(:reason) { "good_reason" }

    it "creates a case note for the case opening" do
      payload = { support_case_id:, agent_id:, reason: }
      expect { handler.case_opened(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.event_type).to eq("case_opened")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.agent_id).to eq(agent_id)
      expect(interaction.additional_data["triggered_by"]).to eq(reason)
    end
  end

  describe "#case_held_by_system" do
    let(:support_case_id) { create(:support_case).id }
    let(:reason) { "reason to be held" }

    it "creates a case note about on-hold status" do
      payload = { support_case_id:, reason: }
      expect { handler.case_held_by_system(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.event_type).to eq("state_change")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.body).to eq("Case placed on hold due to reason to be held")
    end
  end
end
