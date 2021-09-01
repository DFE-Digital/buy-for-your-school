RSpec.describe Support::Category, type: :model do
  it { is_expected.to have_many(:cases) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
