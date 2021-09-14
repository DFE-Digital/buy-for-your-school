RSpec.feature "Create a new journey" do
  context "when the user is signed in" do
    before do
      user_is_signed_in
      visit "/dashboard"
    end

    specify { expect(page).to have_current_path "/dashboard" }

    scenario "they can start a new journey" do
      # TODO: refactor stubbing here
      persist_category(stub_contentful_category(fixture_filename: "radio-question.json"))

      click_create
      click_continue

      expect(page.all("li.govuk-breadcrumbs__list-item").collect(&:text)).to eq \
        ["Dashboard", "Create specification"]

      within "ul.app-task-list__items" do
        expect(find("a.govuk-link")).to have_text "Radio task"
        expect(find("strong.govuk-tag--grey")).to have_text "Not started"
      end
    end

    it "is full page width" do
      expect(page).to have_css "div.govuk-grid-column-full"
    end

    it "dashboard.header" do
      expect(page.title).to have_text "Specifications dashboard"
      expect(find("h1.govuk-heading-xl")).to have_text "Specifications dashboard"
    end

    it "generic.button.back" do
      expect(find("a.govuk-back-link")).to have_text "Back"
    end

    context "when the user has no specifications" do
      it "dashboard.create.header" do
        expect(find("h2.govuk-heading-m")).to have_text "Create a new specification"
      end

      it "dashboard.create.body" do
        expect(find("p.govuk-body")).to have_text "Create a new specification for a catering procurement."
      end

      # duplicates dashboard.create.header
      it "dashboard.create.button" do
        expect(find("a.govuk-button")).to have_text "Create a new specification"
        expect(find("a.govuk-button")[:role]).to eq "button"
      end
    end
  end
end
