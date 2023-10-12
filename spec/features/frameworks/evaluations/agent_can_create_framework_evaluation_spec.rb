require "rails_helper"

xdescribe "Agent can create new framework evaluations", js: true do
  include_context "with a framework evaluation agent"

  let(:framework) { create(:frameworks_framework, status: "pending_evaluation") }

  it "can create a new evaluation from the framework" do
    visit frameworks_framework_path(framework)
    click_on "Evaluations"
    click_on "Add Evaluation"
    select agent.full_name, from: "Assignee"
    click_on "Create Evaluation"
  end
end