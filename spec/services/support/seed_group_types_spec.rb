RSpec.describe Support::SeedGroupTypes do
  subject(:service) do
    described_class.new
  end

  it "populates the tables" do
    expect(Support::GroupType.count).to be_zero
    expect(Support::EstablishmentType.count).to be_zero

    service.call

    expect(Support::GroupType.count).to eq 4
    expect(Support::EstablishmentType.count).to eq 19
  end

  it "resets the data" do
    expect(Support::GroupType.count).to be_zero
    expect(Support::EstablishmentType.count).to be_zero

    service.call

    expect(Support::GroupType.count).to eq 4
    expect(Support::EstablishmentType.count).to eq 19

    service.call

    expect(Support::GroupType.count).to eq 4
    expect(Support::EstablishmentType.count).to eq 19
  end
end
