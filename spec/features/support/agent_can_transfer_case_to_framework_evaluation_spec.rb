require "rails_helper"

describe "Agent can transfer a case to a framework evaluation" do
  let!(:support_case) { create(:support_case) }
  let(:framework) { create(:frameworks_framework) }
  let(:assignee) { create(:support_agent) }

  around do |example|
    Current.set(actor: assignee) do
      example.run
    end
  end

  before do
    create_list(:support_email, 2, ticket: support_case, is_read: false)
    support_case.transfer_to_framework_evaluation(framework_id: framework.id, assignee_id: assignee.id)
  end

  it "closes the case" do
    expect(support_case.state).to eq("closed")
  end

  it "creates a case history entry about the case closure" do
    interaction = support_case.interactions.state_change.last

    expect(interaction.body).to match(/.*Reason given: Evaluation case/)
  end

  it "creates an activity log item about the case closure" do
    expect(Support::ActivityLogItem.where(support_case_id: support_case.id, action: "close_case", data: { closure_reason: "Evaluation case" }).count).to eq(1)
  end

  it "creates an activity log item about the case transfer" do
    evaluation = Frameworks::Evaluation.last

    expect(Support::ActivityLogItem.where(support_case_id: support_case.id, action: "transfer_case", data: { destination_id: evaluation.id, destination_type: evaluation.class.name }).count).to eq(1)
  end

  it "creates a case history entry about the case transfer" do
    interaction = support_case.interactions.case_transferred.last
    evaluation = Frameworks::Evaluation.last

    expect(interaction.body).to eq("Transferred to framework evaluation")
    expect(interaction.agent_id).to eq(assignee.id)
    expect(interaction.additional_data).to eq({ "destination_id" => evaluation.id, "destination_type" => evaluation.class.name })
  end

  it "creates a framework evaluation" do
    evaluation = Frameworks::Evaluation.last

    expect(evaluation.creation_source).to eq("transfer")
  end

  it "creates an activity event about the case transfer on the framework evaluation" do
    evaluation = Frameworks::Evaluation.last
    log_item = evaluation.activity_log_items[1]

    expect(log_item.activity.event).to eq("evaluation_transferred")
    expect(log_item.activity.data).to eq({ "source_id" => support_case.id, "source_type" => support_case.class.name })
  end

  it "moves emails from the case to the framework evaluation" do
    evaluation = Frameworks::Evaluation.last

    expect(support_case.emails.count).to eq(0)
    expect(evaluation.emails.count).to eq(2)
    expect(evaluation.action_required?).to eq(true)
  end
end
