require "rails_helper"

describe CaseManagement::AssignCaseToAgent do
  def assign_case! = described_class.new.call(support_case_id: support_case.id, assigned_by_agent_id: assigned_by.id, assigned_to_agent_id: assigned_to.id)

  let(:support_case) { create(:support_case) }
  let(:assigned_by) { create(:support_agent) }
  let(:assigned_to) { create(:support_agent) }

  it "assigns the case to the agent" do
    expect { assign_case! }.to change { support_case.reload.agent }.to(assigned_to)
  end

  it "broadcasts the agent_assigned_to_case event" do
    with_event_handler(listening_to: :agent_assigned_to_case) do |handler|
      assign_case!

      expect(handler).to have_received(:agent_assigned_to_case).with({
        support_case_id: support_case.id,
        assigned_by_agent_id: assigned_by.id,
        assigned_to_agent_id: assigned_to.id,
      })
    end
  end
end
