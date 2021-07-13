require "rails_helper"

# Rendered text is referred to by the I18n.t key
#
feature "Specification dashboard" do
  context "when the user is not signed in" do
    before do
      visit dashboard_path
    end

    it "redirects to the hompage" do
      expect(page).to have_current_path "/"
    end

    it "specifying.start_page.page_title" do
      expect(page.title).to have_text "Create a specification to procure a catering service for your school"
    end

    it "renders a banner notice" do
      expect(find("h2.govuk-notification-banner__title")).to have_text "Notice"
      expect(find("h3.govuk-notification-banner__heading")).to have_text "You've been signed out."
    end
  end

  context "when the user is signed in" do
    # TODO: create a named user and see their identity in the dashboard
    let(:user) { create(:user) }
    let(:created_at) { Time.zone.local(2021, 2, 15, 12, 0, 0) }

    before do
      user_is_signed_in(user: user)
      visit dashboard_path
    end

    specify { expect(page).to have_current_path "/dashboard" }

    scenario "they can start a new specification" do
      stub_contentful_category(fixture_filename: "radio-question.json")
      click_create_spec_link

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
      end
    end

    context "when they have existing specifications" do
      let(:journey) { create(:journey, user: user, created_at: created_at) }

      before do
        user_is_signed_in(user: user)
        journey
        visit dashboard_path
      end

      it "dashboard.existing.header" do
        expect(find("h2.govuk-heading-m")).to have_text "Existing specifications"
      end

      it "dashboard.existing.body" do
        expect(find("p.govuk-body")).to have_text "Continue with a draft specification, and review completed specifications."
      end

      # duplicates dashboard.create.header
      it "dashboard.create.button" do
        expect(find("a.govuk-button")).to have_text "Create a new specification"
      end

      it "shows tabular data in three columns" do
        expect(page).to have_css "table.govuk-table"
        expect(page).to have_css "td.govuk-table__cell", count: 3
      end

      it "shows the specification creation date in column one" do
        expect(find("td.govuk-table__cell", match: :first)).to have_text "15 February 2021"
      end

      it "shows the specification category title in column two" do
        expect(find("td.govuk-table__cell:nth-of-type(2)")).to have_text "Catering"
      end

      # @see RecordAction
      context "when they revisit an existing journey" do
        it "is recorded in the event log" do
          visit journey_path(journey)

          last_logged_event = ActivityLogItem.last
          expect(last_logged_event.action).to eq("view_journey")
          expect(last_logged_event.journey_id).to eq(journey.id)
          expect(last_logged_event.user_id).to eq(user.id)
          expect(last_logged_event.contentful_category_id).to eq("12345678")
        end
      end
    end
  end
end
