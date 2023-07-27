RSpec.describe Form do
  subject(:form) { described_class.new(user:) }

  let(:user) { create(:user) }

  describe "#step" do
    it "defaults to one" do
      expect(form.step).to be 1
    end
  end

  describe "#messages" do
    it "returns an empty hash" do
      expect(form.messages).to be_a Hash
      expect(form.messages).to be_empty
    end
  end

  describe "#errors" do
    it "#any?" do
      expect(form.errors).to be_a Form::ErrorSummary
      expect(form.errors.any?).to be false
    end

    it "#messages" do
      expect(form.errors.messages).to be_a Hash
      expect(form.errors.messages).to be_empty
    end
  end

  describe "#to_h" do
    it "is not empty" do
      expect(form.to_h).to be_a Hash
      expect(form.to_h).not_to be_empty
    end
  end

  describe "#data" do
    it "associates to the user" do
      expect(form.data).to eq(user_id: user.id)
    end
  end

  describe "#advance!" do
    it "defaults to one move forward" do
      form = described_class.new(step: 99)
      form.advance!
      expect(form.step).to be 100
    end

    it "can skip n steps" do
      form = described_class.new(step: 99)
      form.advance!(2)
      expect(form.step).to be 101
    end
  end

  describe "#back!" do
    it "defaults to one move backward" do
      form = described_class.new(step: 99)
      form.back!
      expect(form.step).to be 98
    end

    it "can skip n steps back" do
      form = described_class.new(step: 99)
      form.back!(2)
      expect(form.step).to be 97
    end
  end
end
