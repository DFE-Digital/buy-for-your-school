RSpec.feature "School data" do
  include_context "with an agent"

  before do
    click_button "Agent Login"
    create(:support_organisation, urn: "1234")
    visit "/support/schools/1234"
  end

  it "show smoke test" do
    expect(page.text).to match(/School #\d/)
  end
end
