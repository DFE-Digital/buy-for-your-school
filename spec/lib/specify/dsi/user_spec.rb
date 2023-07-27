require "dsi/user"

RSpec.describe Dsi::User do
  subject(:user) { described_class.new(user: params) }

  let(:params) do
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
    }
  end

  it "#uid" do
    expect(user.uid).to eq "21D62132-6570-4E63-9DCB-137CC35E7543"
  end

  it "#first_name" do
    expect(user.first_name).to eq "Roger"
  end

  it "#last_name" do
    expect(user.last_name).to eq "Johnson"
  end

  it "#email" do
    expect(user.email).to eq "foo@example.com"
  end

  it "#updated_at" do
    expect(user.updated_at).to eq "2019-06-19T15:09:58.683Z"
  end

  it "#approved_at" do
    expect(user.approved_at).to eq "2019-06-19T15:09:58.683Z"
  end

  it "#organisation_id" do
    expect(user.organisation_id).to eq "13F20E54-79EA-4146-8E39-18197576F023"
  end

  it "#organisation_name" do
    expect(user.organisation_name).to eq "Department for Education"
  end

  it "#organisation_ukprn" do
    expect(user.organisation_ukprn).to be_nil
  end

  it "#organisation_crn" do
    expect(user.organisation_crn).to eq "1234567"
  end

  it "#organisation_category" do
    expect(user.organisation_category).to eq "002"
  end

  it "#organisation_establishment_number" do
    expect(user.organisation_establishment_number).to eq "001"
  end

  it "#role_name" do
    expect(user.role_name).to eq "Approver"
  end

  it "#role_id" do
    expect(user.role_id).to eq 10_000
  end
end
