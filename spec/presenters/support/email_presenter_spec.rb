require "rails_helper"

describe Support::EmailPresenter do
  describe "#body_for_display" do
    include Rails.application.routes.url_helpers

    def expected_url(attachment)
      support_document_download_path(attachment.id, type: "Support::EmailAttachment")
    end

    context "when there are link tags in the email body" do
      subject(:presenter) { described_class.new(email) }
      let(:email) { create(:support_email, body: body) }

      context "with a standard link" do
        let(:body) { "<a href=\"http://example.org?link=1\">Link 1</a>" }

        it "removes the link tags and places the URL beside the link text" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq(
            "Link 1 (http://example.org?link=1)"
          )
        end
      end

      context "with an old fashioned link" do
        let(:body) { "<A href=\"http://example.org?link=1\">Link 1</A>" }

        it "removes the link tags and places the URL beside the link text" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq(
            "Link 1 (http://example.org?link=1)"
          )
        end
      end

      context "with nested links" do
        let(:body) { "<a href=\"http://example.org?link=1\"><span>Check out the following:</span><a href=\"http://example.org?link=2\">Here</a></a>" }

        it "removes the link tags and places the URL beside the link text" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq(
            "Check out the following: (http://example.org?link=1)Here (http://example.org?link=2)"
          )
        end
      end

      context "with javascript as the href" do
        let(:body) { "<a href=\"javascript:doEvil()\">Evil Link</a>" }

        it "removes the link tags completely" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq("")
        end
      end
    end

    context "when there is an inline email attachment" do
      subject(:presenter) { described_class.new(email) }

      let(:email) { create(:support_email, body: "<img src=\"cid:A.B.C\" /> <img src=\"cid:X.Y.Z\" />") }
      let!(:attachment1) { create(:support_email_attachment, is_inline: true, content_id: "A.B.C", email: email) }
      let!(:attachment2) { create(:support_email_attachment, is_inline: true, content_id: "X.Y.Z", email: email) }

      it "replaces each attachment content id with its url" do
        view_context = self # as application route helpers are included

        expect(presenter.body_for_display(view_context)).to eq(
          "<img src=\"#{expected_url(attachment1)}\"> <img src=\"#{expected_url(attachment2)}\">",
        )
      end
    end
  end
end
