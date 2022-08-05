RSpec.describe SupportForm do
  subject(:form) { described_class.new(user:) }

  let(:user) do
    create(:user, :one_supported_school)
  end

  describe "#step" do
    context "with inferred school" do
      it "starts on step 4" do
        expect(form.step).to be 4
      end
    end
  end

  it "#messages" do
    expect(form.messages).to be_a Hash
    expect(form.messages).to be_empty
    expect(form.errors.messages).to be_a Hash
    expect(form.errors.messages).to be_empty
  end

  it "#errors" do
    expect(form.errors).to be_a SupportForm::ErrorSummary
    expect(form.errors.any?).to be false
  end

  it "form params" do
    expect(form.phone_number).to be_nil
    expect(form.journey_id).to be_nil
    expect(form.category_id).to be_nil
    expect(form.message_body).to be_nil
  end

  describe "#data" do
    subject(:form) do
      described_class.new(user:, phone_number: "01234567890", message_body: "hello world")
    end

    it "infers values from the user" do
      expect(form.data).to eql(
        phone_number: "01234567890",
        message_body: "hello world",
        school_urn: "100253",
        user_id: user.id,
      )
    end
  end

  describe "#forward" do
    it "skips journey selection if none exist" do
      form = described_class.new(user:, step: 2)
      form.forward
      expect(form.step).to be 4
    end

    it "skips category selection if a journey is selected" do
      form = described_class.new(user:, step: 3, journey_id: "xxx")
      form.forward
      expect(form.step).to be 5
    end

    it "defaults to stepping forward" do
      form = described_class.new(user:, step: 3)
      form.forward
      expect(form.step).to be 4
    end
  end

  describe "#backward" do
    it "skips journey selection if none exist" do
      form = described_class.new(user:, step: 4)
      form.backward
      expect(form.step).to be 2
    end

    it "skips category selection if a journey is selected" do
      form = described_class.new(user:, step: 5, journey_id: "xxx")
      form.backward
      expect(form.step).to be 3
    end

    it "defaults to stepping backward" do
      form = described_class.new(user:, step: 2)
      form.backward
      expect(form.step).to be 1
    end
  end
end
