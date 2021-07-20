require "rails_helper"

# Rendered text is referred to by the I18n.t key
#
feature "Categories page" do
  context "when the user is not signed in" do
    before do
      visit categories_path
    end

    it "redirects to the homepage" do
      expect(page).to have_current_path "/"
    end

    it "has the home page title" do
      expect(page.title).to have_text "Create a specification to procure a catering service for your school"
    end

    it "renders a banner notice" do
      expect(find("h2.govuk-notification-banner__title")).to have_text "Notice"
      expect(find("h3.govuk-notification-banner__heading")).to have_text "You've been signed out."
    end
  end

  context "when the user is signed in" do
    let(:user) { create(:user) }
    let(:created_at) { Time.zone.local(2021, 2, 15, 12, 0, 0) }

    before do
      user_is_signed_in(user: user)
    end

    it "is full page width" do
      visit categories_path
      expect(page).to have_css "div.govuk-grid-column-full"
    end

    context "and there are no categories" do
      before do
        visit categories_path
      end

      it "has a heading stating that there are no categories" do
        expect(find("h1.govuk-heading-l")).to have_text "No categories found"
      end
    end

    context "and there are two categories" do
      before do
        create(:category, title: "Catering")
        create(:category, title: "MFD")
        visit categories_path
      end

      it "has a form with the right caption" do
        within "div.govuk-form-group" do
          expect(find("legend.govuk-fieldset__legend.govuk-fieldset__legend--l")).to have_text "Choose the type of specification you want to build"
        end
      end

      it "has a form with the right hint" do
        within "div.govuk-form-group" do
          expect(find("div.govuk-hint")).to have_text "We currently only support catering and multifunctional devices."
        end
      end

      it "lists the available categories" do
        within "div.govuk-form-group" do
          find(:radio_button, "Catering")
          find(:radio_button, "MFD")
        end
      end

      it "selects the first category" do
        within "div.govuk-form-group" do
          expect(find(:radio_button, "Catering")).to be_checked
        end
      end

      it "has a Continue button" do
        expect(find("input.govuk-button").value).to eq "Continue"
      end
    end
  end
end
