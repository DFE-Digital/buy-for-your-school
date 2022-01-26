RSpec.describe Support::SeedEstablishmentGroupTypes do
  subject(:service) do
    described_class.new
  end

  it "populates the table" do
    expect(Support::EstablishmentGroupType.count).to be_zero

    service.call

    expect(Support::EstablishmentGroupType.count).to eq 5
  end

  it "resets the data" do
    expect(Support::EstablishmentGroupType.count).to be_zero

    service.call

    expect(Support::EstablishmentGroupType.count).to eq 5

    service.call

    expect(Support::EstablishmentGroupType.count).to eq 5
  end
end
