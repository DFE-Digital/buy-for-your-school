RSpec.feature "NextStepsCatering" do
  before do
    Page.create!(
      title: "Next steps",
      slug: "next_steps_mfd",
      body: Rails.root.join("config/static/next_steps_mfd.md").read,
    )

    visit "/next-steps-mfd"
  end

  describe "body" do
    scenario "contains the expected content regarding next steps" do
      expect(page).to have_title "Next steps"
      expect(page).to have_text "Next steps"
    end
  end
end
