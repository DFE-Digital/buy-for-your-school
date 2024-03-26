require "rails_helper"

describe LocalAuthority, type: :model do
  describe "#eligible_for_school_picker?" do
    let(:local_authority) { create(:local_authority) }

    context "when a local authority has more than one school" do
      before do
        create_list(:support_organisation, 3, local_authority:)
      end

      it "returns true" do
        expect(local_authority.eligible_for_school_picker?).to eq(true)
      end
    end

    context "when a local authority has one school or less" do
      before do
        create(:support_organisation, local_authority:)
      end

      it "returns false" do
        expect(local_authority.eligible_for_school_picker?).to eq(false)
      end
    end
  end
end
