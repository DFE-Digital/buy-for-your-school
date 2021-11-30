RSpec.describe SubmitSupportRequest do
  subject(:service) do
    described_class.new(request: support_request, template: "custom")
  end

  let(:support_case) { Support::Case.last }
  let!(:support_category) { create(:support_category, slug: "slug", title: "Slug") }

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
  end

  describe "#call" do
    before do
      create :support_organisation, urn: "urn-type-1", name: "Specialist School for Testing"
    end

    let(:user) { create(:user, :one_supported_school) }
    let(:chosen_organisation) { user.orgs.first }

    let(:support_request) do
      create(:support_request, :with_specification,
             user: user,
             phone_number: "01234567890",
             school_urn: chosen_organisation["urn"])
    end

    describe "case creation" do
      before { service.call }

      it "submits the request and creates a case" do
        expect(support_case).to be_persisted
        expect(support_case.phone_number).to eq "01234567890"
        expect(support_case.organisation.name).to eq chosen_organisation["name"]
        expect(support_case.organisation.urn).to eq chosen_organisation["urn"]
        expect(support_case.category).to eq support_category
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

    it "send a confirmation email" do
      email = instance_double(::Emails::Confirmation)
      expect(email).to receive(:call)

      allow(Emails::Confirmation).to receive(:new).with(
        recipient: user,
        reference: "000001",
        template: "custom",
        variables: {
          message: "Support request message from a School Buying Professional",
          category: "slug",
        },
      ).and_return(email)

      service.call
    end
  end
end
