RSpec.describe Support::Category, type: :model do
  let(:support_category) { create(:support_category) }

  context "with cases" do
    let!(:support_case) { create(:support_case, category: support_category) }

    it "has case returned in collection" do
      expect(support_category.cases).not_to be_empty
      expect(support_category.cases.first.ref).to eql support_case.ref
    end
  end

  describe "validations" do
    context "with name" do
      it "is valid" do
        expect(support_category).to be_valid
      end
    end

    context "without name" do
      let(:support_category) { build(:support_category, name: nil) }

      it "is not valid" do
        expect(support_category).not_to be_valid
        expect(support_category.errors.full_messages).to include "Name can't be blank"
      end
    end
  end
end
