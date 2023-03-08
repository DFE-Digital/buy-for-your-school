require "rails_helper"

describe "Deleting case files" do
  before { agent_is_signed_in }

  let(:support_case) { create(:support_case) }
  let(:case_file) { create(:support_case_attachment, case: support_case) }

  it "redirects back to case files with the file now deleted" do
    delete support_case_file_path(support_case, case_file)
    expect(Support::CaseAttachment.exists?(case_file.id)).to be(false)
    expect(response).to redirect_to(support_case_path(support_case, anchor: "case-files"))
  end
end
