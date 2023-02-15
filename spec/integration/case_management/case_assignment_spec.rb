require "rails_helper"

describe "Assigning an agent to a case" do
  def assign_agent! = CaseManagement::AssignCaseToAgent.new.call(support_case_id: support_case.id, assigned_by_agent_id:, assigned_to_agent_id:)

  let(:support_case) { create(:support_case) }
  let(:assigned_by_agent_id) { create(:support_agent).id }
  let(:assigned_to_agent_id) { create(:support_agent).id }

  it "assigns the agent to the case" do
    expect { assign_agent! }.to change { support_case.reload.agent_id }.to(assigned_to_agent_id)
  end

  it "records the assignment as a case history log item" do
    expect { assign_agent! }.to change { Support::Interaction.case_assigned.where(case_id: support_case.id).count }.from(0).to(1)
  end

  it "notifies the assigned agent" do
    expect { assign_agent! }.to change { Support::Notification.case_assigned.where(support_case_id: support_case.id, assigned_to_id: assigned_to_agent_id, assigned_by_id: assigned_by_agent_id).count }.from(0).to(1)
  end

  context "when the case is new" do
    let(:support_case) { create(:support_case, :initial) }

    it "opens the case" do
      expect { assign_agent! }.to change { support_case.reload.state }.to("opened")
    end

    it "records the opening as an activity log item" do
      expect { assign_agent! }.to change { Support::ActivityLogItem.where(support_case_id: support_case.id, action: "open_case").count }.from(0).to(1)
    end

    it "records the opening as a case history log item" do
      expect { assign_agent! }.to change { Support::Interaction.case_opened.where(case_id: support_case.id).count }.from(0).to(1)
    end
  end
end
