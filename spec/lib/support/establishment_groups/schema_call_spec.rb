require "support/establishment_groups/schema"

RSpec.describe Support::EstablishmentGroups::Schema, "#call" do
  subject(:schema) { described_class.new }

  let(:result) { schema.call(input) }

  let(:input) do
    {
      ukprn: "1010101",
      name: "Federation of Schools",
      uid: "0001",
      status: "OPEN",
      group_type_code: 1,
      address: {
        street: "High Elms Lane",
        locality: "Garston",
        town: "Watford",
        county: "Hertfordshire",
        postcode: "WD25 0UU",
      },
      opened_date: "06/01/2009",
      closed_date: "31/08/2010",
    }
  end

  it do
    expect(result.errors.to_h).to be_empty
  end
end
