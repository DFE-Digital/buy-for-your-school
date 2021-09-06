RSpec.describe Emails::Document do
  subject(:service) do
    described_class.new(
      recipient: recipient,
      attachment: "./spec/fixtures/gias/example_schools_data.csv",
    )
  end

  let(:recipient) do
    create(:user,
           email: "peter.hamilton@gov.uk",
           first_name: "Peter",
           last_name: "Hamilton",
           full_name: "Mr. Peter Hamilton")
  end

  let(:template_collection) do
    {
      "templates" => [
        # "Default" template
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

  describe "#call" do
    it "adds extra variables" do
      expect(Rollbar).to receive(:info).with("Sending email to peter.hamilton@gov.uk")

      service.call
    end
  end

  describe "#template_params" do
    it "adds extra variables" do
      expect(service.template_params).to eql({
        first_name: "Peter",
        last_name: "Hamilton",
        full_name: "Mr. Peter Hamilton",
      })
    end
  end
end
