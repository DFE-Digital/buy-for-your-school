RSpec.feature "Case worker authentication" do
  include_context "with an agent"

  context "when a current agent" do
    it "redirects user to support root" do
      visit "/cms"
      expect(page).to have_current_path "/support"
    end
  end
end
