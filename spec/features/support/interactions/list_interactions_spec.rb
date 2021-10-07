RSpec.feature "Listing interactions on case history" do
  include_context "with an agent"

  let(:support_case) { create(:support_case, state: "open") }

  context "when agent is signed in" do
    before do
      click_button "Agent Login"
    end

    context "when interaction is a note" do
      let!(:interaction) { create(:support_interaction, :note, case: support_case) }

      before do
        visit "/support/cases/#{support_case.id}"
      end

      it "shows the case note" do
        within "#case-history" do
          expect(find("span#case-history-note-#{interaction.id}")).to have_text "Case note"
        end
      end
    end

    context "when interaction is a phone call" do
      let!(:interaction) { create(:support_interaction, :phone_call, case: support_case) }

      before do
        visit "/support/cases/#{support_case.id}"
      end

      it "shows the phone call" do
        within "#case-history" do
          expect(find("span#case-history-phone-call-#{interaction.id}")).to have_text "Phone call"
        end
      end
    end

    context "when interaction is an email to the school" do
      let!(:interaction) { create(:support_interaction, :email_to_school, case: support_case) }

      before do
        visit "/support/cases/#{support_case.id}"
      end

      it "shows the email to the school" do
        within "#case-history" do
          expect(find("span#case-history-email-to-school-#{interaction.id}")).to have_text "Email to school"
        end
      end
    end

    context "when interaction is an email from the school" do
      let!(:interaction) { create(:support_interaction, :email_from_school, case: support_case) }

      before do
        visit "/support/cases/#{support_case.id}"
      end

      it "shows the email from the school" do
        within "#case-history" do
          expect(find("span#case-history-email-from-school-#{interaction.id}")).to have_text "Email from school"
        end
      end
    end
  end
end
