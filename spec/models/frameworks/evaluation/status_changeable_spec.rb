require "rails_helper"

describe Frameworks::Evaluation::StatusChangeable do
  subject(:evaluation) { build(:frameworks_evaluation, framework:, status: evaluation_status) }

  describe "creating the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "not_approved") }
    let(:evaluation_status) { "draft" }

    it "updates the frameworks status to pending_evaluation" do
      evaluation.save!
      expect(framework.reload.status).to eq("pending_evaluation")
    end
  end

  describe "starting the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "pending_evaluation") }
    let(:evaluation_status) { "draft" }

    it "updates the frameworks status to evaluating" do
      evaluation.mark_as_in_progress!
      expect(framework.reload.status).to eq("evaluating")
    end

    describe "updating the status manually" do
      it "still updates the frameworks status to evaluating" do
        evaluation.update!(status: "in_progress")
        expect(framework.reload.status).to eq("evaluating")
      end
    end
  end

  describe "approving the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "evaluating") }
    let(:evaluation_status) { "in_progress" }

    it "updates the frameworks status to dfe-approved" do
      evaluation.mark_as_approved!
      expect(framework.reload.status).to eq("dfe_approved")
    end
  end

  describe "disaproving the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "evaluating") }
    let(:evaluation_status) { "in_progress" }

    it "updates the frameworks status to not approved" do
      evaluation.mark_as_not_approved!
      expect(framework.reload.status).to eq("not_approved")
    end
  end

  describe "cancelling the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "evaluating") }
    let(:evaluation_status) { "in_progress" }

    it "updates the frameworks status to not approved" do
      evaluation.mark_as_cancelled!
      expect(framework.reload.status).to eq("not_approved")
    end
  end

  describe "available status change options" do
    let(:framework) { create(:frameworks_framework, status: "not_approved") }

    context "when in draft" do
      let(:evaluation_status) { "draft" }

      it "returns available options for this status" do
        expect(evaluation.permissible_status_change_options).to eq([["In progress", "in_progress"]])
      end

      it "can progress status" do
        expect(evaluation.able_to_change_status?).to eq(true)
      end
    end

    context "when in progress" do
      let(:evaluation_status) { "in_progress" }

      it "returns available options for this status" do
        expect(evaluation.permissible_status_change_options).to eq([
          ["Approved", "approved"],
          ["Not approved", "not_approved"],
          ["Cancelled", "cancelled"],
        ])
      end

      it "can progress status" do
        expect(evaluation.able_to_change_status?).to eq(true)
      end
    end

    context "when approved" do
      let(:evaluation_status) { "approved" }

      it "returns available options for this status" do
        expect(evaluation.permissible_status_change_options).to eq([])
      end

      it "cannot progress status" do
        expect(evaluation.able_to_change_status?).to eq(false)
      end
    end

    context "when not approved" do
      let(:evaluation_status) { "not_approved" }

      it "returns available options for this status" do
        expect(evaluation.permissible_status_change_options).to eq([])
      end

      it "cannot progress status" do
        expect(evaluation.able_to_change_status?).to eq(false)
      end
    end

    context "when cancelled" do
      let(:evaluation_status) { "cancelled" }

      it "returns available options for this status" do
        expect(evaluation.permissible_status_change_options).to eq([])
      end

      it "cannot progress status" do
        expect(evaluation.able_to_change_status?).to eq(false)
      end
    end
  end

  describe "validations" do
    context "when framework is already in active evaluation" do
      let(:framework) { create(:frameworks_framework) }

      it "is invalid" do
        # existing evaluation
        create(:frameworks_evaluation, framework:, status: "in_progress")

        # Check 1 : attempting to create a new one
        new_evaluation = build(:frameworks_evaluation, framework:)

        # does not allow a framework in active evaluation
        expect(new_evaluation).not_to be_valid

        # allows a non active framework
        new_evaluation.framework = create(:frameworks_framework)
        expect(new_evaluation).to be_valid

        # Check 2 : saving an existing evaluation
        another_existing_evaluation = create(:frameworks_evaluation, framework: create(:frameworks_framework), status: "in_progress")

        # you can save the evaluation (the framework is in an active evaluation - BUT it is this one so its ok)
        expect(another_existing_evaluation).to be_valid
      end
    end
  end
end
