RSpec.describe Support::SeedSchools do
  subject(:service) { described_class.new(data: gias_data) }

  include_context "with gias data"

  before do
    group_type = create(:support_group_type, code: 4, name: "LA maintained school")
    create(:support_establishment_type, code: 1, name: "Community school", group_type:)
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
