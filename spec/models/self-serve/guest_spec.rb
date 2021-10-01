RSpec.describe Guest do
  subject(:guest) { described_class.new }

  describe "#guest?" do
    specify do
      expect(guest.guest?).to be true
    end
  end

  describe "#agent?" do
    specify do
      expect(guest.agent?).to be false
    end
  end
end
