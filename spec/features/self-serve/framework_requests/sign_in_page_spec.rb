RSpec.feature "Request For Help sign in" do
  describe "has a dynamic back link" do
    let(:back_link) { "/procurement-support/energy_bill" }

    it "links back to the specified page" do
      visit "/procurement-support/sign_in?back_to=#{Base64.encode64(back_link)}"
      click_on "Back"

      expect(page).to have_current_path back_link
    end
  end
end
