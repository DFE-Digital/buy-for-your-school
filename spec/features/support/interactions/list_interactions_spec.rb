RSpec.feature "Listing interactions on case history" do
  let(:support_case) { create(:support_case) }

  context "when agent is signed in" do
    before do
      user_is_signed_in
      visit "/support/cases/#{support_case.id}"
    end

    context "when interaction is a note" do
      before do
        click_link "Add a case note"
      end

      it "shows the add note heading" do
        expect(find("label.govuk-label")).to have_text "Add case note"
      end

      it "allows an agent to add a note" do
        fill_in "interaction[body]", with: "this is an example note"
        click_on "Save"
        expect(find("h3.govuk-notification-banner__heading")).to have_text "Note added to case"
      end
    end

    context "when interaction is logging contact with the school" do
      before do
        click_link "Log contact with school"
      end

      it "shows the log contact with school heading" do
        expect(find("h1.govuk-heading-l")).to have_text "Contact with school"
      end

      context "when choosing a phone call" do
        it "allows agent to log phone call" do
          choose "Phone call"
          fill_in "interaction[body]", with: "this is an example phone call"
          click_on "Save"
          expect(find("h3.govuk-notification-banner__heading")).to have_text "Phone call added to case"
        end
      end

      context "when choosing email from school" do
        it "allows agent to log email from school" do
          choose "Email from school"
          fill_in "interaction[body]", with: "this is an example email from the school"
          click_on "Save"
          expect(find("h3.govuk-notification-banner__heading")).to have_text "Email from school added to case"
        end
      end

      context "when choosing email to school" do
        it "allows agent to log email to school" do
          choose "Email to school"
          fill_in "interaction[body]", with: "this is an example email to the school"
          click_on "Save"
          expect(find("h3.govuk-notification-banner__heading")).to have_text "Email to school added to case"
        end
      end
    end
  end
end
