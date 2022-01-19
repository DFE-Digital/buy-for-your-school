RSpec.feature "FaF - check your answers" do
  before do
    faf = create(:framework_request)
    visit "/procurement-support/#{faf.id}"
  end

  context "when the user is not signed in" do
    it "loads the page" do
      expect(find("h1")).to have_text "Send your request"
    end
  end

  context "when the user is signed in" do
    before do
      user_is_signed_in
    end

    it "loads the page" do
      expect(find("h1")).to have_text "Send your request"
    end
  end
end
