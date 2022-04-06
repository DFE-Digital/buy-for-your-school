RSpec.describe Support::SeedFrameworks do
  subject(:service) { described_class.new(data: framework_data) }

  include_context "with framework data"

  it "populates frameworks" do
    expect(Support::Framework.count).to be_zero
    service.call
    expect(Support::Framework.count).to be 5
  end

  it "resets the data" do
    expect(Support::Framework.count).to be_zero
    service.call
    expect(Support::Framework.count).to be 5
    service.call
    expect(Support::Framework.count).to be 5
  end
end
