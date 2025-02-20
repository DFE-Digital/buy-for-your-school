require "support/establishment_groups/mapper"

RSpec.describe Support::EstablishmentGroups::Mapper, "#call" do
  subject(:mapper) { described_class.new }

  let(:entity) { output.first[key] }

  # The public GIAS "allgroups" CSV file is a historical cumulative record.
  # Consequently there are multiple entries for the same EstablshmentGroup if
  # that establishment group's status or type have changed over time. In some cases
  # there are entries whose only difference is the UID
  #
  let(:output) do
    mapper.call(
      [
        "Group UID" => "0001",
        "UKPRN" => "1010101",
        "Group Name" => "Federation of Schools",
        "Group Type (code)" => "01",
        "Group Status (code)" => "OPEN",
        "Group Street" => "Mustermann Road",
        "Group Locality" => "Kings Norton",
        "Group Town" => "Birmingham",
        "Group County" => "West Midlands",
        "Group Postcode" => "B30 3QG",
        "Open date" => "06/01/2009",
        "Closed Date" => "31/08/2010",
      ],
    )
  end

  describe "uid" do
    let(:key) { :uid }

    specify do
      expect(entity).to eql("0001")
    end
  end

  describe "ukprn" do
    let(:key) { :ukprn }

    specify do
      expect(entity).to eql("1010101")
    end
  end

  describe "name" do
    let(:key) { :name }

    specify do
      expect(entity).to eql("Federation of Schools")
    end
  end

  describe "status" do
    let(:key) { :status }

    specify do
      expect(entity).to eql("OPEN")
    end
  end

  describe "group_type_code" do
    let(:key) { :group_type_code }

    specify do
      expect(entity).to eql("01")
    end
  end

  describe "address" do
    let(:key) { :address }

    specify do
      expect(entity).to eql(
        street: "Mustermann Road",
        locality: "Kings Norton",
        town: "Birmingham",
        county: "West Midlands",
        postcode: "B30 3QG",
      )
    end
  end

  describe "opened_date" do
    let(:key) { :opened_date }

    specify do
      expect(entity).to eql("06/01/2009")
    end
  end

  describe "closed_date" do
    let(:key) { :closed_date }

    specify do
      expect(entity).to eql("31/08/2010")
    end
  end
end
