require "rails_helper"

describe "Agent can create new framework evaluations", :js do
  include_context "with a framework evaluation agent"

  let(:framework) { create(:frameworks_framework) }

  it "can create a new evaluation from the framework" do
    visit frameworks_framework_path(framework)
    click_on "Evaluations"
    click_on "Add Evaluation"
    select agent.full_name, from: "Case Owner"

    click_on "Create evaluation"

    expect(page).to have_current_path(%r{/frameworks/evaluations/})
    expect(framework.reload.evaluations.count).to eq(1)
  end
end
