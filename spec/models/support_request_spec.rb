RSpec.describe SupportRequest, type: :model do

  it "belongs to a user" do
    association = described_class.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:message) }
  end
end
