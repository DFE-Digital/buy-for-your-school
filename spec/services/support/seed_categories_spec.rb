RSpec.describe Support::SeedCategories do
  subject(:service) do
    described_class.new
  end

  let(:parent_categories) { Support::Category.where(parent_id: nil).order(title: :asc) }
  let(:sub_categories) { Support::Category.where.not(parent_id: nil).order(title: :asc) }

  it "populates the tables" do
    expect(parent_categories.count).to be 0
    expect(sub_categories.count).to be 0

    service.call

    expect(parent_categories.count).to be 12
    expect(sub_categories.count).to be 54
  end

  describe "resetting the data" do
    context "when reset is false" do
      it "leaves the data intact" do
        service.call

        first_run_parents = parent_categories.pluck(:id, :parent_id, :title)
        first_run_sub_categories = sub_categories.pluck(:id, :parent_id, :title)

        service.call

        second_run_parents = parent_categories.pluck(:id, :parent_id, :title)
        second_run_sub_categories = sub_categories.pluck(:id, :parent_id, :title)

        expect(first_run_parents).to eq(second_run_parents)
        expect(first_run_sub_categories).to eq(second_run_sub_categories)
      end
    end
  end

  context "when a category has sub categories" do
    it "nests the sub categories under the parent" do
      service.call

      ict = Support::Category.find_by(title: "ICT")
      sub_categories = ict.sub_categories.pluck(:title)
      websites_category = Support::Category.find_by(title: "Websites")

      expect(sub_categories).to include("Peripherals")
      expect(sub_categories).to include("Cyber services")
      expect(sub_categories).to include("Websites")
      expect(websites_category.parent.title).to eq("ICT")
    end
  end

  context "when a sub category has the same name as the parent" do
    it "creates them both linking them as parent and sub category" do
      service.call

      expect(Support::Category.where(title: "Furniture").count).to be 2
      parent = Support::Category.find_by(title: "Furniture", parent_id: nil)
      expect(parent.sub_categories.pluck(:title)).to eq(%w[Furniture])
    end
  end
end
