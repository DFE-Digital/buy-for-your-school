#
# Assert how interactions are created and appear in the case history
#

# New case event
#   when interaction is a note
#     shows add note heading
#     logs note in case history
#     Back link
#       behaves like breadcrumb_back_link
#         has correct url in breadcrumb back link
#   when interaction is a phone call or email
#     shows log contact with school heading
#     when choosing phone call
#       logs phone call in case history
#     when choosing email from school
#       logs email from school in case history
#     when choosing email to school
#       logs email to school in case history
#     Back link
#       behaves like breadcrumb_back_link
#         has correct url in breadcrumb back link
#
RSpec.feature "New case event" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, state: "opened", ref: "987654") }

  before do
    click_button "Agent Login"
    visit "/support/cases/#{support_case.id}"
  end

  context "when interaction is a note" do
    before do
      click_link "Add a case note"
    end

    describe "Back link" do
      it_behaves_like "breadcrumb_back_link" do
        let(:url) { "/support/cases/#{support_case.id}" }
      end
    end

    it "shows add note heading" do
      expect(find("label.govuk-label")).to have_text "Add a note to case 987654"
    end

    it "logs note in case history" do
      fill_in "interaction[body]", with: "this is an example note"

      click_on "Save"
      expect(find("h3.govuk-notification-banner__heading")).to have_text "Note added to case"

      visit "/support/cases/#{support_case.id}#case-history"
      within "#case-history" do
        expect(page).to have_text "Case note"
      end
    end
  end

  context "when interaction is a phone call or email" do
    before do
      click_link "Log contact with school"
    end

    describe "Back link" do
      it_behaves_like "breadcrumb_back_link" do
        let(:url) { "/support/cases/#{support_case.id}" }
      end
    end

    it "shows log contact with school heading" do
      expect(find("h1.govuk-heading-l")).to have_text "Contact with school"
    end

    context "when choosing phone call", js: true do
      it "logs phone call in messages" do
        choose "Phone call"
        fill_in "interaction[body]", with: "this is an example phone call"

        click_on "Save"
        expect(find("h3.govuk-notification-banner__heading")).to have_text "Phone call added to case"

        visit "/support/cases/#{support_case.id}#messages"
        within "#messages-frame" do
          click_link "View"
          expect(page).to have_text "Phone call"
        end
      end
    end

    context "when choosing email from school", js: true do
      it "logs email from school in messages" do
        choose "Email from school"
        fill_in "interaction[body]", with: "this is an example email from the school"

        click_on "Save"
        expect(find("h3.govuk-notification-banner__heading")).to have_text "Email from school added to case"

        visit "/support/cases/#{support_case.id}#messages"
        within "#messages-frame" do
          click_link "View"
          expect(page).to have_text "Email from school"
          expect(page).to have_text "this is an example email from the school"
        end
      end
    end

    context "when choosing email to school", js: true do
      it "logs email to school in messages" do
        choose "Email to school"
        fill_in "interaction[body]", with: "this is an example email to the school"

        click_on "Save"
        expect(find("h3.govuk-notification-banner__heading")).to have_text "Email to school added to case"

        visit "/support/cases/#{support_case.id}#messages"
        within "#messages-frame" do
          click_link "View"
          expect(page).to have_text "first_name last_name"
          expect(page).to have_text "this is an example email to the school"
        end
      end
    end
  end
end
