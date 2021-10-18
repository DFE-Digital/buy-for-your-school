RSpec.describe Support::SeedGroups do
  subject(:service) do
    described_class.new
  end

  it "populates the tables" do
    expect(Support::Group.count).to be_zero
    expect(Support::EstablishmentType.count).to be_zero

    service.call

    expect(Support::Group.count).to eq 4
    expect(Support::EstablishmentType.count).to eq 18
  end

  it "resets the data" do
    expect(Support::Group.count).to be_zero
    expect(Support::EstablishmentType.count).to be_zero

    service.call

    expect(Support::Group.count).to eq 4
    expect(Support::EstablishmentType.count).to eq 18

    service.call

    expect(Support::Group.count).to eq 4
    expect(Support::EstablishmentType.count).to eq 18
  end
end
