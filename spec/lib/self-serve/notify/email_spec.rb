require "notify/email"

RSpec.describe Notify::Email do
  let(:recipient) do
    OpenStruct.new(
      email: "email@gov.uk",
      first_name: "first_name",
      last_name: "last_name",
    )
  end

  let(:template_collection) do
    {
      "templates" => [
        # letter
        {
          "id" => "f163deaf-2d3f-4ec6-98fc-f23fa511518f",
          "name" => "My template name",
          "type" => "letter",
          "created_at" => "2016-11-29T11:12:30.12354Z",
          "updated_at" => "2016-11-29T11:12:40.12354Z",
          "created_by" => "jane.doe@gmail.com",
          "body" => "Contents of template ((place_holder))",
          "subject" => "Subject of the letter",
          "version" => "2",
          "letter_contact_block" => "The return address",
        },
        # email
        {
          "id" => "da6f6c37-8d34-49d3-b9cf-b45fb74cedff",
          "name" => "Default",
          "type" => "email",
          "from_email" => "ghbs@notifications.service.gov.uk",
          "created_at" => "2021-08-26T09:00:00.12345Z",
          "updated_at" => "2021-08-26T09:00:00.12345Z",
          "created_by" => "example@gov.uk",
          "body" => "Hello ((first_name)) ((last name)), \r\n\r\nDownload your document at: ((link_to_file))",
          "subject" => "Test",
          "version" => "4",
        },
      ],
    }
  end

  let(:email_response) do
    {
      "id" => "aceed36e-6aee-494c-a09f-88b68904bad6",
      "reference" => nil,
      "content" => {
        "body" => "Hello we got your application",
        "subject" => "Application recieved",
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
    # fetch template by name
    stub_request(:get,
                 "https://api.notifications.service.gov.uk/v2/templates?type=email").to_return(
                   body: template_collection.to_json,
                 )

    # send email
    stub_request(:post,
                 "https://api.notifications.service.gov.uk/v2/notifications/email").to_return(
                   body: email_response.to_json,
                   status: 201,
                   headers: { "Content-Type" => "application/json" },
                 )
  end

  describe "default behaviour" do
    subject(:service) do
      described_class.new(recipient: recipient)
    end

    it "connects to the defined service" do
      expect(service.client.service_id).to eql "12345678-1234-1234-1234-abcd12345678"
    end

    it "contacts the Notify API endpoint" do
      expect(service.client.base_url).to eql "https://api.notifications.service.gov.uk"
    end

    it "uses the 'Default' email template" do
      expect(service.template).to eql "Default"
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
      expect { described_class.new(recipient: recipient) }.to raise_error ArgumentError
    end
  end

  context "with an attachment" do
    subject(:service) do
      described_class.new(
        recipient: recipient,
        attachment: "./spec/fixtures/gias/example_schools_data.csv",
      )
    end

    it "returns a response notification" do
      expect(service.call).to be_a Notifications::Client::ResponseNotification
    end
  end

  context "when message invalid" do
    subject(:service) do
      described_class.new(recipient: recipient)
    end

    let(:invalid_email_response) do
      {
        "errors" => [{ "error" => "test", "message" => "test" }],
      }
    end

    before do
      stub_request(:post,
                   "https://api.notifications.service.gov.uk/v2/notifications/email").to_return(
                     body: invalid_email_response.to_json,
                     status: 400,
                     headers: { "Content-Type" => "application/json" },
                   )
    end

    it "returns an error notification" do
      expect(service.call).to eq "test: test"
    end
  end
end
