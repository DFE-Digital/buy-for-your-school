describe "Cec agent can add attachments to replies", :js, :with_csrf_protection do
  include_context "with a cec agent"

  let(:email) { create(:support_email, :inbox, ticket: support_case) }
  let(:dfe_energy_category) { create(:support_category, title: "DfE Energy for Schools service") }
  let(:support_case) { create(:support_case, category: dfe_energy_category) }

  before do
    create(:support_interaction, :email_from_school,
           body: email.body,
           additional_data: { email_id: email.id },
           case: support_case)

    visit cec_onboarding_case_path(support_case)
  end

  context "when replying to an email from the school" do
    before do
      click_on "Messages"

      within("#messages-frame") do
        click_on "View"
        click_on "Reply with signature"
        fill_in_editor "Your message", with: "This is a test reply"
      end
    end

    describe "allows agent to add attachments" do
      before do
        attach_file(Rails.root.join("spec/support/assets/support/email_attachments/attachment.txt"), class: "dz-hidden-input", make_visible: true)
        sleep 0.5 # allow file to finish uploading
      end

      it "shows the attached file" do
        within("#reply-frame") do
          expect(page).to have_text "attachment.txt"
        end
      end

      it "allows agent to remove attachments" do
        within("#reply-frame") do
          click_on "Remove"
          expect(page).not_to have_text "attachment.txt"
        end
      end
    end
  end
end
