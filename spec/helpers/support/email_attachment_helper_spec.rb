require "rails_helper"

RSpec.describe Support::EmailAttachmentHelper do
  describe "email_attachment_container" do
    before do
      allow(helper).to receive(:render)
    end

    it "renders the view" do
      helper.email_attachment_container
      expect(helper).to have_received(:render).with("support/helpers/email_attachment_container")
    end
  end
end
