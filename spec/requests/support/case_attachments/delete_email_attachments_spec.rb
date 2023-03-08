require "rails_helper"

describe "Deleting email attachments" do
  before { agent_is_signed_in }

  let(:attachment) { create(:support_email_attachment, hidden: false).tap { |a| a.email.update!(case: support_case) } }
  let(:support_case) { create(:support_case) }

  it "redirects back to attachments with the attachment now hidden from view" do
    delete support_case_attachment_path(support_case, attachment)
    expect(attachment.reload.hidden).to be(true)
    expect(response).to redirect_to(support_case_path(support_case, anchor: "case-attachments"))
  end
end
