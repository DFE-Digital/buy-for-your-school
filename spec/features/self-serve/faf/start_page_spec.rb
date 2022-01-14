RSpec.feature "Faf - start page" do
  context "when the user is not signed in" do
    before do
      visit "/procurement-support"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Request help and support with your procurement"
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/procurement-support"
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Request help and support with your procurement"
    end
  end
end
