require "rails_helper"

describe CaseHistory::HandleCaseStateChanges do
  subject(:handler) { described_class.new }

  describe "#agent_assigned_to_case" do
    let(:support_case_id) { create(:support_case).id }
    let(:assigned_by_agent_id) { create(:support_agent).id }
    let(:assigned_to_agent_id) { create(:support_agent).id }

    it "creates a case note for the assignment" do
      payload = { support_case_id:, assigned_by_agent_id:, assigned_to_agent_id: }
      expect { handler.agent_assigned_to_case(payload) }.to change(Support::Interaction, :count).from(0).to(1)
      interaction = Support::Interaction.last
      expect(interaction.event_type).to eq("case_assigned")
      expect(interaction.case_id).to eq(support_case_id)
      expect(interaction.agent_id).to eq(assigned_by_agent_id)
      expect(interaction.additional_data["assigned_to_agent_id"]).to eq(assigned_to_agent_id)
    end
  end

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
end
