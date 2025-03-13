require "rails_helper"

describe "Agent can review evaluations", type: :request do
  let(:user) { create(:user, :caseworker) }
  let!(:agent) { Support::Agent.find_or_create_by_user(user).tap { |agent| agent.update!(roles: %i[procops framework_evaluator]) } }
  let(:support_case) { create(:support_case, email: user.email) }
  let(:file_1) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
  let(:document_uploader) { support_case.document_uploader(files: [file_1]) }

  before do
    Current.actor = agent
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)
    document_uploader.save_evaluation_document!(user.email, true)
  end

  it "check agent can download the document evaluation" do
    last_document = Support::EvaluatorsUploadDocument.last
    put support_document_download_path(support_case, document_type: "Support::EvaluatorsUploadDocument", document_id: last_document.id)

    expect(response).to have_http_status(:success)
    expect(response.headers["Content-Type"]).to eq("text/plain")
  end
end
