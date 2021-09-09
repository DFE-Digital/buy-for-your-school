RSpec.describe Support::SeedCategories do
  subject(:service) do
    described_class.new
  end

  it "populates the tables" do
    expect(Support::Category.count).to be 0
    expect(Support::SubCategory.count).to be 0

    service.call

    expect(Support::Category.count).to be 12
    expect(Support::SubCategory.count).to be 54
  end

  it "resets the data" do
    expect(Support::Category.count).to be 0
    expect(Support::SubCategory.count).to be 0

    service.call

    expect(Support::Category.count).to be 12
    expect(Support::SubCategory.count).to be 54

    service.call

    expect(Support::Category.count).to be 12
    expect(Support::SubCategory.count).to be 54
  end
end
