RSpec.describe Support::SeedEstablishmentGroups do
  subject(:service) { described_class.new(data: establishment_group_data) }

  include_context "with establishment group data"

  before do
    create(:support_establishment_group_type, code: 1, name: "Federation")
  end

  it "populates supported organisations only" do
    expect(Support::EstablishmentGroup.count).to be_zero
    service.call
    expect(Support::EstablishmentGroup.count).to be 1
  end

  it "resets the data" do
    expect(Support::EstablishmentGroup.count).to be_zero
    service.call
    expect(Support::EstablishmentGroup.count).to be 1
    service.call
    expect(Support::EstablishmentGroup.count).to be 1
  end
end
