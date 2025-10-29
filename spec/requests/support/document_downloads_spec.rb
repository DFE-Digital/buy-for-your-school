require "rails_helper"

describe "Document downloads" do
  let!(:email_attachment) { create(:support_email_attachment) }

  describe "Accessing an email attachment" do
    context "when agent is not logged in" do
      it "redirects to the CMS login page" do
        get support_document_download_path(email_attachment, type: "Support::EmailAttachment")
        expect(response).to redirect_to("/cms/sign-in")
      end
    end
  end

  describe "Accessing an invalid document type" do
    context "when agent is logged in" do
      before { agent_is_signed_in }

      it "renders 415" do
        get support_document_download_path(email_attachment, type: "SomethingRandom")
        expect(response.status).to eq(415)
      end
    end
  end
end
