require "rails_helper"

describe "Support agent sends a templated email" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, :open) }

  before do
    click_button "Agent Login"
    visit support_case_path(support_case)
    click_link "Send email"
  end

  it "renders a message explaining the feature is not yet implemented" do
    choose "Template"
    click_button "Save"
    expect(page).to have_content("not yet implemented")
  end
end
