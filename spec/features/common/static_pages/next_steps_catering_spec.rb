RSpec.feature "NextStepsCatering" do
  before do
    Page.create!(
      title: "Next Steps",
      slug: "next_steps_catering",
      body: File.read("config/static/next_steps_catering.md"),
    )
    visit "/next-steps-catering"
  end

  describe "body" do
    scenario "contains the expected content regarding next steps" do
      expect(page).to have_text("Next steps")
      expect(page).to have_title("Next Steps")
    end
  end
end
