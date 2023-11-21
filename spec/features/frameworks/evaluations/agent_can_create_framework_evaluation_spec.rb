require "rails_helper"

describe "Agent can create new framework evaluations", js: true do
  include_context "with a framework evaluation agent"

  let(:framework) { create(:frameworks_framework) }

  it "can create a new evaluation from the framework" do
    visit frameworks_framework_path(framework)
    click_on "Evaluations"
    click_on "Add Evaluation"
    select agent.full_name, from: "Case Owner"

    expect { click_on "Create evaluation" }.to change { framework.reload.evaluations.count }.from(0).to(1)
  end
end
