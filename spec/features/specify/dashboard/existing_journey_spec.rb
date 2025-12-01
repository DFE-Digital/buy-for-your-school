RSpec.feature "View existing journeys" do
  # TODO: create a named user and see their identity in the dashboard
  context "when the user is signed in" do
    let(:user) { create(:user) }

    context "with existing journeys" do
      before do
        create(:journey,
               user:,
               name: "MFD123",
               category: create(:category, :mfd),
               created_at: Time.zone.local(2021, 2, 15, 12, 0, 0),
               updated_at: Time.zone.local(2021, 2, 15, 12, 0, 0))

        create(:journey,
               user:,
               name: "Catering456",
               category: create(:category, :catering),
               created_at: Time.zone.local(2021, 3, 20, 12, 0, 0),
               updated_at: Time.zone.local(2021, 3, 20, 12, 0, 0))

        user_is_signed_in(user:)
        visit "/dashboard"
      end

      it "dashboard.breadcrumbs" do
        expect(page.all("li.govuk-breadcrumbs__list-item").collect(&:text)).to eq \
          %w[Dashboard]
      end

      it "dashboard.existing.header" do
        expect(find("h2.govuk-heading-m", text: "Existing specifications")).to be_present
      end

      it "dashboard.existing.body" do
        expect(find("p.govuk-body", text: "Continue with a draft specification, and review completed specifications.")).to be_present
      end

      # duplicates dashboard.create.header
      it "dashboard.create.button" do
        expect(find("a.govuk-button")).to have_text "Create a new specification"
        expect(find("a.govuk-button")[:role]).to eq "button"
      end

      it "shows tabular data in four columns" do
        expect(page).to have_css "table.govuk-table"
        expect(page).to have_css "td.govuk-table__cell", count: 10
      end

      it "shows the spec name in column one" do
        expect(find(:xpath, "//table/thead/tr[1]/th[1]")).to have_text "Name"
        expect(find(:xpath, "//table/tbody/tr[1]/td[1]")).to have_text "MFD123"
        expect(find(:xpath, "//table/tbody/tr[2]/td[1]")).to have_text "Catering456"
      end

      it "shows the category title in column two" do
        expect(find(:xpath, "//table/thead/tr[1]/th[2]")).to have_text "Category"
        expect(find(:xpath, "//table/tbody/tr[1]/td[2]")).to have_text "Multi-functional devices"
        expect(find(:xpath, "//table/tbody/tr[2]/td[2]")).to have_text "Catering"
      end

      it "shows the creation date in column three" do
        expect(find(:xpath, "//table/thead/tr[1]/th[4]")).to have_text "Date started"
        expect(find(:xpath, "//table/tbody/tr[1]/td[4]")).to have_text "15 February 2021"
        expect(find(:xpath, "//table/tbody/tr[2]/td[4]")).to have_text "20 March 2021"
      end

      it "redirects to the specification page" do
        click_link "MFD123"

        expect(find("h1.govuk-heading-xl", text: "Your specification")).to be_present
      end
    end

    context "when the journey does not belong to the user" do
      before do
        create(:journey, user: create(:user))

        user_is_signed_in(user:)
        visit "/dashboard"
      end

      scenario "that journey is not shown" do
        # dashboard.existing.header
        expect(page).not_to have_content("Existing specifications")
      end
    end
  end
end
