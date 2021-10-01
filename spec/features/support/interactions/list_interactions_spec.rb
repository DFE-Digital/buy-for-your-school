RSpec.feature "Listing interactions on case history" do
  let(:support_case) { create(:support_case, state: 1) }

  context "when agent is signed in" do
    before do
      user_is_signed_in
    end

    context "when interaction is a note" do
      before do
        create(:support_interaction, :note, case: support_case)
        visit "/support/cases/#{support_case.id}"
      end

      it "shows the interactions" do
        within "#case-history" do
          expect(find("span#accordion-case-history-enquiry-heading")).to have_text "Case note"
        end
      end
    end
  end
end
