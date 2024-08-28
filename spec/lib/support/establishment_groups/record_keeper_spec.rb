require "support/establishment_groups/record_keeper"

RSpec.describe Support::EstablishmentGroups::RecordKeeper do
  subject(:record_keeper) { described_class.new }

  let(:saved_keys) do
    %i[
      establishment_group_type_id
      name
      address
      status
      ukprn
      uid
      opened_date
      closed_date
    ]
  end

  let(:record) do
    {
      uid: "0001",
      ukprn: "117576",
      name: "Federation of Schools",
      status: "OPEN",
      group_type_code: 1,
      address: {
        street: "Mustermann Road",
        locality: "Kings Norton",
        town: "Birmingham",
        county: "West Midlands",
        postcode: "B30 3QG",
      },
      opened_date: "06/01/2009",
      closed_date: "31/08/2010",
    }
  end

  describe "#call" do
    context "with a set of records including a record for a closed and opened organisation" do
      before { create(:support_establishment_group_type, code: 1) }

      it "persists the opened organisation" do
        expect { record_keeper.call([record]) }.to change(Support::EstablishmentGroup, :count).by(1)
        expect(Support::EstablishmentGroup.last.uid).to eq(record[:uid])
      end

      it "saves data to the fields chosen" do
        record_keeper.call([record])

        saved_keys.each do |key|
          expect(Support::EstablishmentGroup.last.send(key).blank?).to be(false)
        end
      end
    end
  end
end
