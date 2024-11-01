require "rails_helper"

RSpec.describe Support::EstablishmentGroup, type: :model do
  subject(:establishment_group) { create(:support_establishment_group, establishment_group_type:) }

  let(:federation_type) { create(:support_establishment_group_type, code: 1) }
  let(:trust_type) { create(:support_establishment_group_type, code: 2) }

  let(:establishment_group_type) { federation_type }

  it { is_expected.to belong_to(:establishment_group_type) }

  describe "#organisations" do
    context "when the group is a federation" do
      let(:establishment_group_type) { federation_type }

      before do
        create(:support_organisation, name: "Fed School 1", federation_code: establishment_group.uid)
        create(:support_organisation, name: "Fed School 2", federation_code: establishment_group.uid)
        create(:support_organisation, name: "Fed School 3", federation_code: "1234")
      end

      it "returns associated organisations" do
        expect(establishment_group.organisations.pluck(:name)).to contain_exactly("Fed School 1", "Fed School 2")
      end
    end

    context "when the group is a trust" do
      let(:establishment_group_type) { trust_type }

      before do
        create(:support_organisation, name: "Trust School 1", trust_code: establishment_group.uid)
        create(:support_organisation, name: "Trust School 2", trust_code: establishment_group.uid)
        create(:support_organisation, name: "Trust School 3", trust_code: "1234")
      end

      it "returns associated organisations" do
        expect(establishment_group.organisations.pluck(:name)).to contain_exactly("Trust School 1", "Trust School 2")
      end
    end
  end
end
