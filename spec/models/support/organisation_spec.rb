RSpec.describe Support::Organisation, type: :model do
  it { is_expected.to belong_to(:establishment_type) }

  describe "#postcode" do
    it "returns the value stored in address" do
      organisation = described_class.new(address: { postcode: "S1 2JF" })
      expect(organisation.postcode).to eq("S1 2JF")
    end
  end

  describe "#urn" do
    it "is unique" do
      group_type = create(:support_group_type, code: 4, name: "LA maintained school")
      type = create(:support_establishment_type, code: 1, name: "Community school", group_type: group_type)
      create(:support_organisation, urn: "unique", establishment_type: type)

      # persistence level
      # expect { create(:support_organisation, urn: "unique") }.to raise_error ActiveRecord::RecordNotUnique

      # ActiveRecord validation
      expect { create(:support_organisation, urn: "unique") }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  it "#secondary?" do
    expect(create(:support_organisation, phase: 4)).to be_secondary
  end

  it "#opened?" do
    expect(create(:support_organisation, status: 1)).to be_opened
  end

  it "#mixed?" do
    expect(create(:support_organisation, gender: 3)).to be_mixed
  end
end
