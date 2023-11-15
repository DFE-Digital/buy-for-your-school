require "rails_helper"

describe "Agent can move emails to a case" do
  let!(:source_case) { create(:support_case, action_required: true) }
  let!(:destination_case) { create(:support_case) }
  let(:agent) { create(:support_agent) }

  let(:email_mover) do
    source_case.email_mover(
      destination_id: destination_case.id,
      destination_type: destination_case.class.name,
      destination_ref: destination_case.ref,
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

    it "moves emails from the source case to the destination case" do
      expect { email_mover.save! }.to(
        change { source_case.emails.count }.from(2).to(0)
        .and(change { destination_case.emails.count }.from(0).to(2)),
      )
    end

    it "updates the source case and destination case statuses" do
      expect { email_mover.save! }.to(
        change(source_case, :closed?).from(false).to(true)
        .and(change(source_case, :closure_reason).from(nil).to("email_merge"))
        .and(change(source_case, :action_required?).from(true).to(false))
        .and(change { destination_case.reload.action_required? }.from(false).to(true)),
      )
    end

    it "creates email merge interactions on the source and destination cases" do
      expect { email_mover.save! }.to(
        change { source_case.interactions.email_merge.count }.from(0).to(1)
        .and(change { destination_case.interactions.email_merge.count }.from(0).to(1)),
      )
      expect(source_case.interactions.email_merge.first.body).to eq("to ##{destination_case.ref}")
      expect(destination_case.interactions.email_merge.first.body).to eq("from ##{source_case.ref}")
    end
  end

  context "when the source case has interactions" do
    before do
      create_list(:support_interaction, 2, case_id: source_case.id)
    end

    it "moves the interactions from the source case to the destination case" do
      expect { email_mover.save! }.to(
        change { destination_case.interactions.count }.from(0).to(3)
        .and(not_change { source_case.interactions.count }),
      )
    end
  end

  context "when the destination case is the same as the source" do
    let(:email_mover) do
      source_case.email_mover(
        destination_id: source_case.id,
        destination_type: source_case.class.name,
        destination_ref: source_case.ref,
      )
    end

    it "fails validation" do
      expect(email_mover).not_to be_valid
      expect(email_mover.errors.messages[:destination_ref]).to eq ["You cannot merge into the same case"]
    end
  end

  context "when only the destination case reference is provided" do
    let(:email_mover) do
      source_case.email_mover(
        destination_id: nil,
        destination_type: nil,
        destination_ref: "123",
      )
    end

    it "fails validation" do
      expect(email_mover).not_to be_valid
      expect(email_mover.errors.messages[:destination_ref]).to eq ["You must choose a valid case"]
    end
  end
end
