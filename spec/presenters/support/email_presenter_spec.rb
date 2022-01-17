require "rails_helper"

describe Support::EmailPresenter do
  describe "#body_with_inline_attachments" do
    include Rails.application.routes.url_helpers

    def expected_url(attachment)
      support_document_download_path(attachment.id, type: "Support::EmailAttachment")
    end

    context "when there is an inline email attachment" do
      subject(:presenter) { described_class.new(email) }

      let(:email) { create(:support_email, body: "<img src=\"cid:A.B.C\" /> <img src=\"cid:X.Y.Z\" />") }
      let!(:attachment1) { create(:support_email_attachment, is_inline: true, content_id: "A.B.C", email: email) }
      let!(:attachment2) { create(:support_email_attachment, is_inline: true, content_id: "X.Y.Z", email: email) }

      it "replaces each attachment content id with its url" do
        view_context = self # as application route helpers are included

        expect(presenter.body_with_inline_attachments(view_context)).to eq(
          "<img src=\"#{expected_url(attachment1)}\" /> <img src=\"#{expected_url(attachment2)}\" />",
        )
      end
    end
  end
end
