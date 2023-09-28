require "rails_helper"

describe Frameworks::Evaluation::StatusChangeable do
  subject(:evaluation) { Frameworks::Evaluation.new(framework:, status: evaluation_status) }

  describe "starting the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "pending_evaluation") }
    let(:evaluation_status) { "draft" }

    it "updates the frameworks status to evaluating" do
      evaluation.start!
      expect(framework.reload.status).to eq("evaluating")
    end
  end

  describe "approving the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "evaluating") }
    let(:evaluation_status) { "in_progress" }

    it "updates the frameworks status to dfe-approved" do
      evaluation.approve!
      expect(framework.reload.status).to eq("dfe_approved")
    end
  end

  describe "disaproving the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "evaluating") }
    let(:evaluation_status) { "in_progress" }

    it "updates the frameworks status to not approved" do
      evaluation.disapprove!
      expect(framework.reload.status).to eq("not_approved")
    end
  end

  describe "cancelling the evaluation" do
    let(:framework) { create(:frameworks_framework, status: "evaluating") }
    let(:evaluation_status) { "in_progress" }

    it "updates the frameworks status to not approved" do
      evaluation.cancel!
      expect(framework.reload.status).to eq("not_approved")
    end
  end
end
