RSpec.feature "Categories page" do
  context "when the user is not signed in" do
    before do
      visit "/categories"
    end

    it "redirects to the homepage" do
      expect(page).to have_current_path "/"
    end

    it "specifying.start_page.page_title" do
      expect(page.title).to have_text "Create a specification to procure for your school"
    end

    it "renders a banner notice" do
      expect(find("h2.govuk-notification-banner__title")).to have_text "Notice"
      expect(find("h3.govuk-notification-banner__heading")).to have_text "You must sign in."
    end
  end

  context "when designers have been previewing" do
    specify "the preview category is not rendered" do
      stub_contentful_entry(
        entry_id: "radio-question",
        fixture_filename: "steps/radio-question.json",
      )

      user_is_signed_in
      visit "/preview/entries/radio-question"
      visit "/categories"
      expect(find("h1.govuk-heading-l")).to have_text "No categories found"
    end
  end

  describe "as an authenticated user" do
    let(:user) { create(:user) }
    let(:created_at) { Time.zone.local(2021, 2, 15, 12, 0, 0) }

    before do
      stub_multiple_contentful_categories(category_fixtures: ["mfd-radio-question.json"])
      user_is_signed_in(user: user)
    end

    context "when there are no categories" do
      it "auto-populates from Contentful" do
        visit "/categories"

        expect(Category.count).to eq 1

        within "div.govuk-form-group" do
          find(:radio_button, "Multi-function devices") # from mfd-radio-question.json
        end
      end
    end

    context "when there is a category" do
      before do
        create(:category, :mfd)
        visit "/categories"
      end

      it "is full page width" do
        expect(page).to have_css "div.govuk-grid-column-full"
      end

      it "title categories.header" do
        expect(page.title).to have_text "What are you buying?"
      end

      it "legend categories.header" do
        within "div.govuk-form-group" do
          expect(find("legend.govuk-fieldset__legend.govuk-fieldset__legend--l")).to have_text "What are you buying?"
        end
      end

      it "has a Continue button" do
        expect(find("input.govuk-button").value).to eq "Continue"
      end
    end

    context "when there are multiple categories" do
      before do
        create(:category, :mfd)
        create(:category, :catering)
        create(:category, title: "New category of spend")
        visit "/categories"
      end

      it "lists the available categories alphabetically" do
        within "div.govuk-form-group" do
          find(:radio_button, "Catering")
          find(:radio_button, "Multi-functional devices")
          find(:radio_button, "New category of spend")
        end
      end

      it "defaults to selecting the first category" do
        within "div.govuk-form-group" do
          expect(find(:radio_button, "Catering")).to be_checked
          expect(find(:radio_button, "Multi-functional devices")).not_to be_checked
        end
      end
    end
  end
end
