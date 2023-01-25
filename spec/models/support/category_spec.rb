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
    context "with title" do
      it "is valid" do
        expect(support_category).to be_valid
      end
    end

    context "without title" do
      let(:support_category) { build(:support_category, title: nil) }

      it "is invalid" do
        expect(support_category).not_to be_valid
        expect(support_category.errors.full_messages).to include "Title can't be blank"
      end
    end
  end

  describe ".change_sub_category_parent!" do
    it "changes the given sub category's parent to the given parent category by title" do
      office_supplies = create(:support_category, title: "Office Supplies")
      books_parent = create(:support_category, title: "Books")
      books_sub_category = create(:support_category, title: "Books", parent: books_parent)

      described_class.change_sub_category_parent!(sub_category_title: "Books", new_parent_category_title: "Office Supplies")

      expect(books_sub_category.reload.parent).to eq(office_supplies)
    end
  end
end
