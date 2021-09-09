RSpec.describe Support::SeedSchools do
  subject(:service) do
    # fixture contains 3 schools
    # the "voluntary aided school" is skipped
    # the "closed" school is skipped
    described_class.new(data: "spec/fixtures/gias/example_schools_data.csv")
  end

  before do
    group = create(:support_group, code: 4, name: "LA maintained school")
    create(:support_establishment_type, code: 1, name: "Community school", group: group)
  end

  it "populates supported organisations only" do
    expect(Support::Organisation.count).to be_zero
    service.call
    expect(Support::Organisation.count).to be 1
  end

  it "resets the data" do
    expect(Support::Organisation.count).to be_zero
    service.call
    expect(Support::Organisation.count).to be 1
    service.call
    expect(Support::Organisation.count).to be 1
  end
end
