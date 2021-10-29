RSpec.describe SubmitSupportRequest do
  subject(:service) do
    described_class.new(request: support_request, template: "custom")
  end

  let(:support_case) { Support::Case.last }

  let(:template_collection) do
    {
      "templates" => [
        {
          "name" => "custom",
        },
      ],
    }
  end

  before do
    # fetch template by name
    stub_request(:get,
                 "https://api.notifications.service.gov.uk/v2/templates?type=email").to_return(
                   body: template_collection.to_json,
                 )

    # send email
    stub_request(:post,
                 "https://api.notifications.service.gov.uk/v2/notifications/email").to_return(
                   body: {}.to_json,
                   status: 201,
                   headers: { "Content-Type" => "application/json" },
                 )

    # submit
    service.call
  end

  describe "#call" do
    let(:user) { create(:user, :one_supported_school) }
    let(:chosen_organisation) { user.orgs.first }

    let(:support_request) do
      create(:support_request, :with_specification,
             user: user,
             phone_number: "01234567890",
             school_urn: chosen_organisation["urn"])
    end

    it "submits the request and creates a case" do
      expect(support_case).to be_persisted
      expect(support_case.phone_number).to eq "01234567890"
      expect(support_case.organisation_name).to eq chosen_organisation["name"]
      expect(support_case.organisation_urn).to eq chosen_organisation["urn"]
      # expect(support_case.category).to eq "slug"
    end

    context "with a specification" do
      it "attaches the specification as a document" do
        expect(support_case.documents.count).to eq 1
      end
    end

    context "without a specification" do
      let(:support_request) { create(:support_request) }

      it "has no support document" do
        expect(support_case.documents.count).to eq 0
      end
    end
  end
end
