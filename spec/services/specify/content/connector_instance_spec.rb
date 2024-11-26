RSpec.describe Content::Connector, ".instance" do
  subject(:connector) do
    described_class.instance(space_id, delivery_token, preview_token)
  end

  let(:space_id) { "abc" }
  let(:environment) { "test" }
  let(:delivery_token) { "delivery" }
  let(:preview_token) { "preview" }

  around do |example|
    ClimateControl.modify(
      CONTENTFUL_SPACE: space_id,
      CONTENTFUL_ENVIRONMENT: environment,
      CONTENTFUL_DELIVERY_TOKEN: delivery_token,
      CONTENTFUL_PREVIEW_TOKEN: preview_token,
    ) do
      example.run
    end
  end

  describe "#client" do
    it "selects either the 'delivery' or 'preview' client" do
      delivery_client = instance_double(Contentful::Client)
      allow(Contentful::Client).to receive(:new)
        .with(application_name: "DfE: Buy For Your School",
              application_version: "1.0.0",
              api_url: "cdn.contentful.com",
              space: space_id,
              environment:,
              raise_errors: true,
              access_token: delivery_token)
        .and_return(delivery_client)

      preview_client = instance_double(Contentful::Client)
      allow(Contentful::Client).to receive(:new)
        .with(application_name: "DfE: Buy For Your School",
              application_version: "1.0.0",
              api_url: "preview.contentful.com",
              space: space_id,
              environment:,
              raise_errors: true,
              access_token: preview_token)
        .and_return(preview_client)

      expect(connector.client(:delivery)).to eq delivery_client
      expect(connector.client(:preview)).to eq preview_client
    end

    context "when neither 'preview' or 'delivery' are chosen" do
      it "raises an error" do
        expect {
          connector.client(:unknown)
        }.to raise_error Content::Connector::UnexpectedClient, "must be either 'preview' or 'delivery'"
      end
    end
  end
end
