RSpec.describe Support::SeedCategories do
  subject(:service) do
    described_class.new
  end

  let(:parent_categories) { Support::Category.where(parent_id: nil) }
  let(:sub_categories) { Support::Category.where.not(parent_id: nil) }

  it "populates the tables" do
    expect(parent_categories.count).to be 0
    expect(sub_categories.count).to be 0

    service.call

    expect(parent_categories.count).to be 12
    expect(sub_categories.count).to be 54
  end

  it "resets the data" do
    expect(parent_categories.count).to be 0
    expect(sub_categories.count).to be 0

    service.call

    expect(parent_categories.count).to be 12
    expect(sub_categories.count).to be 54

    service.call

    expect(parent_categories.count).to be 12
    expect(sub_categories.count).to be 54
  end

  context "when a category has sub categories" do
    it "nests the sub categories under the parent" do
      service.call

      ict = Support::Category.find_by(title: "ICT")
      sub_categories = ict.sub_categories.pluck(:title)

      expect(sub_categories).to include("Peripherals")
      expect(sub_categories).to include("Cyber services")
      expect(sub_categories).to include("Websites")

      websites = Support::Category.find_by(title: "Websites")

      expect(websites.parent.title).to eq("ICT")
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
