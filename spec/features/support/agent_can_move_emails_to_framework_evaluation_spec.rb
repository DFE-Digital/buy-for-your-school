require "rails_helper"

describe "Agent can move emails to a framework evaluation" do
  let!(:source_case) { create(:support_case, action_required: true) }
  let!(:destination_framework_evaluation) { create(:frameworks_evaluation) }
  let(:agent) { create(:support_agent) }

  let(:email_mover) do
    source_case.email_mover(
      destination_id: destination_framework_evaluation.id,
      destination_type: destination_framework_evaluation.class.name,
      destination_ref: destination_framework_evaluation.ref,
    )
  end

  around do |example|
    Current.set(actor: agent) do
      example.run
    end
  end

  context "when source case has emails attached" do
    before do
      create_list(:support_email, 2, ticket: source_case, is_read: false)
    end

    it "moves emails from the source case to the destination evaluation" do
      expect { email_mover.save! }.to(
        change { source_case.emails.count }.from(2).to(0)
        .and(change { destination_framework_evaluation.emails.count }.from(0).to(2)),
      )
    end

    it "updates the source case and destination evaluation statuses" do
      expect { email_mover.save! }.to(
        change(source_case, :closed?).from(false).to(true)
        .and(change(source_case, :closure_reason).from(nil).to("email_merge"))
        .and(change(source_case, :action_required?).from(true).to(false))
        .and(change { destination_framework_evaluation.reload.action_required? }.from(false).to(true)),
      )
    end

    it "creates email merge interaction on the source case and email merge activity on the destination evaluation" do
      expect { email_mover.save! }.to(
        change { source_case.interactions.email_merge.count }.from(0).to(1)
        .and(change { destination_framework_evaluation.activity_log_items.count }.from(1).to(3)),
      )
      expect(source_case.interactions.email_merge.first.body).to eq("to ##{destination_framework_evaluation.ref}")
      expect(destination_framework_evaluation.activity_log_items[-2].activity.event).to eq("emails_moved_from")
      expect(destination_framework_evaluation.activity_log_items[-2].activity.data).to eq({ "source_id" => source_case.id, "source_type" => source_case.class.name })
    end
  end
end
