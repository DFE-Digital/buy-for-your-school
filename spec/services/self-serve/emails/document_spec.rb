RSpec.describe Emails::Document do
  subject(:service) do
    described_class.new(
      recipient:,
      template: "f6895ff7-86e0-4d38-80ab-c9525856c3ff",
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
    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/email")
    .to_return(body: email_response.to_json, status: 201, headers: {})
  end

  describe "#call" do
    it "adds extra variables" do
      expect(Rollbar).to receive(:info).with("Sending email")

      service.call
    end
  end
end
