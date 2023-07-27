require "notify/email"

RSpec.describe Notify::Email do
  let(:recipient) do
    OpenStruct.new(
      email: "email@gov.uk",
      first_name: "first_name",
      last_name: "last_name",
    )
  end

  let(:response) do
    {
      "id" => "aceed36e-6aee-494c-a09f-88b68904bad6",
      "reference" => nil,
      "content" => {
        "body" => "Hello we got your application",
        "subject" => "Application received",
        "from_email" => "example@gov.uk",
      },
      "template" => {
        "id" => "f6895ff7-86e0-4d38-80ab-c9525856c3ff",
        "version" => 1,
        "uri" => "/v2/templates/f6895ff7-86e0-4d38-80ab-c9525856c3ff",
      },
      "uri" => "/notifications/aceed36e-6aee-494c-a09f-88b68904bad6",
    }
  end

  before do
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
    .to_return(body: response.to_json, status: 201, headers: { "Content-Type" => "application/json" })
  end

  describe "default behaviour" do
    subject(:service) do
      described_class.new(recipient:, template: "xxx")
    end

    it "connects to the defined service" do
      expect(service.client.service_id).to eql "12345678-1234-1234-1234-abcd12345678"
    end

    it "contacts the Notify API endpoint" do
      expect(service.client.base_url).to eql "https://api.notifications.service.gov.uk"
    end

    it "assigns a default message reference" do
      expect(service.reference).to eql "generic"
    end

    it "returns a response notification" do
      expect(service.call).to be_a Notifications::Client::ResponseNotification
    end
  end

  context "with an invalid API key" do
    around do |example|
      ClimateControl.modify(NOTIFY_API_KEY: "xxx") do
        example.run
      end
    end

    it "the client raises an error" do
      expect { described_class.new(recipient:, template: "xxx") }.to raise_error ArgumentError
    end
  end

  context "with an attachment" do
    subject(:service) do
      described_class.new(
        recipient:,
        template: "xxx",
        attachment: "./spec/fixtures/gias/example_schools_data.csv",
      )
    end

    it "returns a response notification" do
      expect(service.call).to be_a Notifications::Client::ResponseNotification
    end
  end

  context "when message invalid" do
    subject(:service) do
      described_class.new(recipient:, template: "xxx")
    end

    let(:response) do
      { "errors" => [{ "error" => "test", "message" => "test" }] }
    end

    before do
      stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
      .to_return(body: response.to_json, status: 400, headers: { "Content-Type" => "application/json" })
    end

    it "returns an error notification" do
      expect(service.call).to eq "test: test"
    end
  end
end
