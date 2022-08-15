require "rails_helper"

describe Support::Messages::OutlookMessagePresenter do
  include ActionView::TestCase::Behavior

  subject(:presenter) { described_class.new(email) }

  let(:email) { create(:support_email) }

  describe "#body_for_display" do
    include Rails.application.routes.url_helpers

    def expected_url(attachment)
      support_document_download_path(attachment.id, type: "Support::EmailAttachment")
    end

    context "when there are link tags in the email body" do
      let(:email) { create(:support_email, unique_body:) }

      context "with a standard link" do
        let(:unique_body) { "<a href=\"http://example.org?link=1\">Link 1</a>" }

        it "removes the link tags and places the URL beside the link text" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq(
            "Link 1 (http://example.org?link=1) ",
          )
        end
      end

      context "with an old fashioned link" do
        let(:unique_body) { "<A href=\"http://example.org?link=1\">Link 1</A>" }

        it "removes the link tags and places the URL beside the link text" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq(
            "Link 1 (http://example.org?link=1) ",
          )
        end
      end

      context "with nested links" do
        let(:unique_body) { "<a href=\"http://example.org?link=1\"><span>Check out the following:</span><a href=\"http://example.org?link=2\">Here</a></a>" }

        it "removes the link tags and places the URL beside the link text" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq(
            "Check out the following: (http://example.org?link=1) Here (http://example.org?link=2) ",
          )
        end
      end

      context "with javascript as the href" do
        let(:unique_body) { "<a href=\"javascript:doEvil()\">Evil Link</a>" }

        it "removes the link tags completely" do
          view_context = self  # as application route helpers are included

          expect(presenter.body_for_display(view_context)).to eq("")
        end
      end
    end

    context "when there is an inline email attachment" do
      let(:email) { create(:support_email, unique_body: "<img src=\"cid:A.B.C\" /> <img src=\"cid:X.Y.Z\" />") }
      let!(:attachment1) { create(:support_email_attachment, is_inline: true, content_id: "A.B.C", email:) }
      let!(:attachment2) { create(:support_email_attachment, is_inline: true, content_id: "X.Y.Z", email:) }

      it "replaces each attachment content id with its url" do
        view_context = self # as application route helpers are included

        expect(presenter.body_for_display(view_context)).to eq(
          "<img src=\"#{expected_url(attachment1)}\"> <img src=\"#{expected_url(attachment2)}\">",
        )
      end
    end
  end

  describe "#case_reference" do
    context "when there is no case" do
      let(:email) { create(:support_email, case: nil) }

      it "returns nil" do
        expect(presenter.case_reference).to be_nil
      end
    end

    context "when there is a case" do
      let(:email) { create(:support_email, case: create(:support_case, ref: "000001")) }

      it "returns the case reference" do
        expect(presenter.case_reference).to eq "000001"
      end
    end
  end

  describe "#case_org_name" do
    context "when there is no case" do
      let(:email) { create(:support_email, case: nil) }

      it "returns nil" do
        expect(presenter.case_org_name).to be_nil
      end
    end

    context "when there is a case" do
      let(:email) { create(:support_email, case: create(:support_case, organisation: create(:support_organisation, name: "School"))) }

      it "returns the organisation name" do
        expect(presenter.case_org_name).to eq "School"
      end
    end
  end

  describe "#sent_by_email" do
    context "when there is no sender" do
      let(:email) { create(:support_email, sender: nil) }

      it "returns nil" do
        expect(presenter.sent_by_email).to be_nil
      end
    end

    context "when there is a sender" do
      it "returns the sender's email" do
        expect(presenter.sent_by_email).to eq "sender1@email.com"
      end
    end
  end

  describe "#sent_by_name" do
    context "when there is no sender" do
      let(:email) { create(:support_email, sender: nil) }

      it "returns nil" do
        expect(presenter.sent_by_name).to be_nil
      end
    end

    context "when there is a sender" do
      it "returns the sender's name" do
        expect(presenter.sent_by_name).to eq "Sender 1"
      end
    end
  end

  describe "#message_recap" do
    context "when the email is not a reply" do
      let(:email) { create(:support_email, in_reply_to: nil) }

      it "returns nil" do
        expect(presenter.message_recap(nil)).to be_nil
      end
    end

    context "when the email is a reply" do
      let(:in_reply_to) { create(:support_email, body: "message body") }
      let(:email) { create(:support_email, in_reply_to:) }

      it "returns the body of the previous message" do
        expect(presenter.message_recap(nil)).to eq "<p>message body</p>"
      end
    end
  end

  describe "#truncated_body_for_display" do
    let(:email) do
      create(
        :support_email,
        unique_body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi aliquet, nibh ullamcorper dolor.",
      )
    end

    it "truncates the message body after 90 chars" do
      expect(presenter.truncated_body_for_display(view)).to eq "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi aliquet, nibh ullamcorpe..."
    end
  end

  describe "#can_save_attachments?" do
    context "when there are non-inline attachments" do
      before { create(:support_email_attachment, email:) }

      it "returns true" do
        expect(presenter.can_save_attachments?).to eq true
      end
    end

    context "when there are no non-inline attachments" do
      before { create(:support_email_attachment, is_inline: true, email:) }

      it "returns false" do
        expect(presenter.can_save_attachments?).to eq false
      end
    end
  end

  describe "#can_mark_as_read?" do
    context "when the email comes from the inbox" do
      let(:email) { create(:support_email, :inbox) }

      it "returns true" do
        expect(presenter.can_mark_as_read?).to eq true
      end
    end

    context "when the email does not come from the inbox" do
      let(:email) { create(:support_email, :sent_items) }

      it "returns false" do
        expect(presenter.can_mark_as_read?).to eq false
      end
    end
  end

  describe "#attachments_for_display" do
    let!(:attachment1) { create(:support_email_attachment, email:) }
    let!(:attachment2) { create(:support_email_attachment, email:) }
    let!(:attachment3) { create(:support_email_attachment, is_inline: true, email:) }

    it "returns all non-inline attachments" do
      expect(presenter.attachments_for_display.size).to eq 2
      expect(presenter.attachments_for_display[0]).to eq attachment1
      expect(presenter.attachments_for_display[1]).to eq attachment2
      expect(presenter.attachments_for_display).not_to include attachment3
    end
  end

  describe "#render_actions" do
    it "renders the message actions" do
      expect(view).to receive(:render).with("support/cases/message_threads/outlook/actions", message: presenter)

      presenter.render_actions(view)
    end
  end

  describe "#render_details" do
    it "renders the message details" do
      expect(view).to receive(:render).with("support/cases/message_threads/outlook/details", message: presenter)

      presenter.render_details(view)
    end
  end

  describe "#sent_at_formatted" do
    let(:email) { create(:support_email, sent_at:) }

    before { travel_to Time.zone.local(2022, 8, 10) }

    after { travel_back }

    context "when the sent_at date was yesterday" do
      let(:sent_at) { Time.zone.parse("09/08/2022 10:30") }

      it "returns formatted date" do
        expect(presenter.sent_at_formatted).to eq "Yesterday at 10:30"
      end
    end

    context "when the sent_at date is today" do
      let(:sent_at) { Time.zone.parse("10/08/2022 10:30") }

      it "returns formatted date" do
        expect(presenter.sent_at_formatted).to eq "Today at 10:30"
      end
    end

    context "when the sent_at date is at some other point" do
      let(:sent_at) { Time.zone.parse("01/01/2022 10:30") }

      it "returns formatted date" do
        expect(presenter.sent_at_formatted).to eq "01 Jan 10:30"
      end
    end
  end
end
