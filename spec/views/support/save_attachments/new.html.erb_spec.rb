require "rails_helper"

describe "support/save_attachments/new" do
  describe "file type excluded warning" do
    before do
      view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

      email = create(:support_email)
      attachment = create(:support_email_attachment, email:)
      attachment.update!(file_type:)

      assign(:save_attachments_form, Support::SaveAttachmentsForm.from_email(email))
      assign(:email, email)
      assign(:subject, email.subject)
      assign(:back_url, "#")
    end

    context "with an excluded file type saved as an email attachment" do
      let(:file_type) { "application/exe" }

      it "shows warning" do
        render
        expect(rendered).to match(/Attachments that cannot be saved due to their field type have been excluded./)
      end
    end

    context "with no excluded file types saved as email attachments" do
      let(:file_type) { "text/plain" }

      it "doesnt show warning" do
        render
        expect(rendered).not_to match(/Attachments that cannot be saved due to their field type have been excluded./)
      end
    end
  end
end
