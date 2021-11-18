RSpec.feature "NextStepsCatering" do
  before do
    Page.create!(
      title: "Next steps catering",
      slug: "next_steps_catering",
      body: Rails.root.join("config/static/next_steps_catering.md").read,
    )

    visit "/next-steps-catering"
  end

  xdescribe "body" do
    scenario "contains the expected content regarding next steps" do
      expect(page).to have_title "Next steps catering"
      expect(page).to have_text "Next steps"
    end

    it "shows the breadcrumbs" do
      expect(page).to have_breadcrumbs ["Dashboard", "Next steps"]
    end
  end
end
