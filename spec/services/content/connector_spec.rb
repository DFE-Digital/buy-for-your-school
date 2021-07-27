RSpec.describe Content::Connector do
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
    it "instantiates clients for both delivery and preview endpoints" do
      delivery_client = instance_double(Contentful::Client)
      allow(Contentful::Client).to receive(:new)
        .with(application_name: "DfE: Buy For Your School",
              application_version: "1.0.0",
              api_url: "cdn.contentful.com",
              space: space_id,
              environment: environment,
              raise_errors: true,
              access_token: delivery_token)
        .and_return(delivery_client)

      preview_client = instance_double(Contentful::Client)
      allow(Contentful::Client).to receive(:new)
        .with(application_name: "DfE: Buy For Your School",
              application_version: "1.0.0",
              api_url: "preview.contentful.com",
              space: space_id,
              environment: environment,
              raise_errors: true,
              access_token: preview_token)
        .and_return(preview_client)

      expect(connector.client(:delivery)).to eq delivery_client
      expect(connector.client(:preview)).to eq preview_client
    end
  end
end
