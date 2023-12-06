require "rails_helper"

describe "support/case_requests/show.html.erb" do
  before do
    define_basic_categories
    controller.request.path_parameters[:id] = case_request.id
    assign(:case_request, case_request)
  end

  context "when an organisation has not been selected" do
    let(:case_request) { CaseRequest.new(id: SecureRandom.uuid, discovery_method: 0) }

    it "says 'No organisation selected'" do
      render
      expect(rendered).to match(/No organisation selected/)
    end
  end

  context "when an organisation has been selected" do
    let(:case_request) { CaseRequest.new(id: SecureRandom.uuid, discovery_method: 0, organisation: create(:support_organisation, name: "Test Organisation")) }

    it "displays the organisation name" do
      render
      expect(rendered).to match(/Test Organisation/)
    end
  end
end
