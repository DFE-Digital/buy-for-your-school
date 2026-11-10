RSpec.feature "Starting a 'Find a Framework' request", :with_csrf_protection do
  let(:start_page) do
    OpenStruct.new(
      title: "Request help buying for your school",
      body: "Get help from our procurement specialists.\n\n[==Start now==>](/procurement-support/start)",
      related_content: [],
      attachments: [],
      parent: nil,
      slug: "procurement-support",
    )
  end

  before do
    allow(FABS::Page).to receive(:find_by_slug!).with("procurement-support").and_return(start_page)

    visit "/procurement-support"
  end

  it "shows the start page content from Contentful" do
    expect(page).to have_text "Get help from our procurement specialists."
    expect(page).to have_button "Start now"
  end

  it "loads without requiring authentication" do
    expect(page).to have_current_path "/procurement-support"
  end

  describe "for authenticated users", :js do
    before do
      user_exists_in_dfe_sign_in

      visit "/procurement-support"
      click_on "Start now"
      choose "Yes, use my DfE Sign-in"
      click_continue
    end

    it "shows their profile" do
      expect(page).to have_current_path "/procurement-support/confirm_sign_in"
      expect(page).to have_button "Yes, continue"
    end

    describe "when user signs out" do
      before do
        click_on "Sign out"
      end

      it "redirects to the start page" do
        expect(page).to have_current_path "/procurement-support"
        expect(page).to have_content "You have been signed out."
      end
    end
  end
end
