RSpec.describe Guest do
  subject(:guest) { described_class.new }

  describe "#guest?" do
    specify do
      expect(guest.guest?).to be true
    end
  end

  describe "#admin?" do
    specify do
      expect(guest.admin?).to be false
    end
  end
end
