RSpec.feature "Interacting with a case" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, state: "open") }

  before { visit "/support/cases/#{support_case.id}" }

  describe "adding a note" do
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

  describe "logging contact with the school" do
    before do
      click_link "Log contact with school"
    end

    it "shows the log contact with school heading" do
      expect(find("h1.govuk-heading-l")).to have_text "Contact with school"
    end

    describe "by phone" do
      it "logs phone call from school" do
        choose "Phone call"
        fill_in "interaction[body]", with: "phone call"
        click_on "Save"
        expect(find("h3.govuk-notification-banner__heading")).to have_text "Phone call added to case"
      end
    end

    describe "by email" do
      it "logs email from school" do
        choose "Email from school"
        fill_in "interaction[body]", with: "email from the school"
        click_on "Save"
        expect(find("h3.govuk-notification-banner__heading")).to have_text "Email from school added to case"
      end
    end
  end
end
