require "rails_helper"

describe "Assigning an agent to a case" do
  def assign_agent!
    Current.set(agent: assigned_by_agent) do
      support_case.assign_to_agent(assigned_to_agent)
    end
  end

  let(:support_case) { create(:support_case) }
  let(:assigned_by_agent) { create(:support_agent) }
  let(:assigned_to_agent) { create(:support_agent) }

  it "assigns the agent to the case" do
    expect { assign_agent! }.to change { support_case.reload.agent }.to(assigned_to_agent)
  end

  it "records the assignment as a case history log item" do
    expect { assign_agent! }.to change { Support::Interaction.case_assigned.where(case_id: support_case.id).count }.from(0).to(1)
  end

  it "notifies the assigned agent" do
    expect { assign_agent! }.to change { Support::Notification.case_assigned.where(support_case_id: support_case.id, assigned_to_id: assigned_to_agent.id, assigned_by_id: assigned_by_agent.id).count }.from(0).to(1)
  end
end
