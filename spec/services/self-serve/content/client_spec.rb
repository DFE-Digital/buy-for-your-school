RSpec.describe Content::Client do
  subject(:client) { described_class.new }

  let(:contentful_client) { instance_double(Contentful::Client) }

  before do
    allow(Contentful::Client).to receive(:new).and_return(contentful_client)
  end

  after do
    # #<InstanceDouble(Contentful::Client) (anonymous)> was originally created in
    # one example but has leaked into another example and can no longer be used.
    # rspec-mocks' doubles are designed to only last for one example, and you need
    # to create a new one in each example you wish to use it for.
    Content::Connector.reset!
  end

  describe "#space" do
    it do
      allow(contentful_client).to receive(:space).and_return(double(id: "space_id"))
      expect(client.space).to eq "space_id"
    end
  end

  describe "#environment" do
    it do
      allow(contentful_client).to receive(:configuration).and_return(environment: "test_env")
      expect(client.environment).to eq "test_env"
    end
  end

  describe "#base_url" do
    it do
      allow(contentful_client).to receive(:base_url).and_return("base_url")
      expect(client.base_url).to eq "base_url"
    end
  end

  describe "#api_url" do
    it do
      allow(contentful_client).to receive(:configuration).and_return(api_url: "api_url")
      expect(client.api_url).to eq "api_url"
    end
  end

  # describe "#locales" do
  #   it do
  #   end
  # end

  # describe "#content_types" do
  #   it do
  #   end
  # end

  describe "#by_id" do
    it "returns a Contentful::Entry" do
      entry = instance_double(Contentful::Entry)
      allow(contentful_client).to receive(:entry).with("123").and_return(entry)

      expect(client.by_id("123")).to eq entry
    end
  end

  describe "#by_type" do
    it "returns a Contentful::Array" do
      array = instance_double(Contentful::Array)
      allow(contentful_client).to receive(:entries).with(content_type: "test_type").and_return(array)

      expect(client.by_type("test_type")).to eq array
    end
  end

  describe "#by_slug" do
    it "returns a Contentful::Entry" do
      entry = instance_double(Contentful::Entry)
      array = instance_double(Contentful::Array)

      allow(array).to receive(:first).and_return(entry)
      allow(contentful_client).to receive(:entries).with(content_type: "category", "fields.slug" => "mfd").and_return(array)

      expect(client.by_slug(:category, "mfd")).to eq entry
    end
  end
end
