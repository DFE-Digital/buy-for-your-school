require "dsi/client"

RSpec.describe Dsi::Client do
  subject(:client) { described_class.new }

  let(:url) { "https://example.com" }
  let(:response) { "" }

  before do
    travel_to Time.zone.local(2000, 0o1, 0o1, 0o0, 0o0, 0o0)

    stub_request(:get, url).to_return(status: 200, body: response, headers: {})
  end

  describe "#jwt" do
    it "generates a valid token" do
      payload, header = JWT.decode(client.jwt, "secret", true, { algorithm: "HS256" })

      expect(payload).to eql(
        "iss" => "service",
        "exp" => 946_684_860,
        "aud" => "signin.education.gov.uk",
      )

      expect(header).to eq("alg" => "HS256")
    end
  end

  describe "#users" do
    let(:response) do
      {
        "users" => [
          {
            "approvedAt" => "2019-06-19T15:09:58.683Z",
            "updatedAt" => "2019-06-19T15:09:58.683Z",
            "organisation" => {
              "id" => "13F20E54-79EA-4146-8E39-18197576F023",
              "name" => "Department for Education",
              "Category" => "002",
              "Type" => nil,
              "URN" => nil,
              "UID" => nil,
              "UKPRN" => nil,
              "EstablishmentNumber" => "001",
              "Status" => 1,
              "ClosedOn" => nil,
              "Address" => nil,
              "phaseOfEducation" => nil,
              "statutoryLowAge" => nil,
              "statutoryHighAge" => nil,
              "telephone" => nil,
              "regionCode" => nil,
              "legacyId" => "1031237",
              "companyRegistrationNumber" => "1234567",
              "createdAt" => "2019-02-20T14:27:59.020Z",
              "updatedAt" => "2019-02-20T14:28:38.223Z",
            },
            "roleName" => "Approver",
            "roleId" => 10_000,
            "userId" => "21D62132-6570-4E63-9DCB-137CC35E7543",
            "email" => "foo@example.com",
            "familyName" => "Johnson",
            "givenName" => "Roger",
          },
        ],
        "numberOfRecords" => 1,
        "page" => 1,
        "numberOfPages" => 1,
      }.to_json
    end

    let(:url) { "https://test-api.signin.education.gov.uk/users" }

    it "returns an array of users" do
      expect(client.users).to be_a Array
      expect(client.users.first).to be_a Dsi::User
      expect(client.users.first.first_name).to eql "Roger"
    end
  end

  describe "#roles" do
    let(:response) do
      { "roles" => [{ "code" => "The code of the role" }] }.to_json
    end

    let(:url) { "https://test-api.signin.education.gov.uk/services/service/organisations/foo/users/bar" }

    it "returns an array of users" do
      expect(client.roles(user_id: "bar", org_id: "foo")).to eql ["The code of the role"]
    end
  end

  describe "#orgs" do
    let(:response) do
      [{ "name" => "Department for Education" }].to_json
    end

    let(:url) { "https://test-api.signin.education.gov.uk/users/bar/organisations" }

    it "returns an array of organisations" do
      expect(client.orgs(user_id: "bar").first["name"]).to eql "Department for Education"
    end
  end
end
