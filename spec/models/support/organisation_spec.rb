RSpec.describe Support::Organisation, type: :model do
  it { is_expected.to belong_to(:establishment_type) }

  describe "#urn" do
    it "is unique" do
      group = create(:support_group, code: 4, name: "LA maintained school")
      type = create(:support_establishment_type, code: 1, name: "Community school", group: group)
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
