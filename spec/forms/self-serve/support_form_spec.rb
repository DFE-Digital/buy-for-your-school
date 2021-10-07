RSpec.describe SupportForm, type: :model do
  subject(:form) { described_class.new }

  it "#step" do
    expect(form.step).to be 1
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

  # respond to
  it "form params" do
    expect(form.phone_number).to be_nil
    expect(form.journey_id).to be_nil
    expect(form.category_id).to be_nil
    expect(form.message_body).to be_nil
  end

  describe "#to_h" do
    context "when populated" do
      subject(:form) do
        described_class.new(phone_number: "01234567890", message_body: "hello world")
      end

      it "has values" do
        expect(form.to_h).to eql({
          phone_number: "01234567890",
          message_body: "hello world",
        })
      end
    end

    context "when unpopulated" do
      it "is empty" do
        expect(form.to_h).to be_empty
      end
    end
  end

  it "#advance!" do
    form = described_class.new(step: 99)
    form.advance!
    expect(form.step).to be 100
  end

  it "#skip!" do
    form = described_class.new(step: 99)
    form.skip!
    expect(form.step).to be 101
  end

  it "#back" do
    form = described_class.new(step: 99)
    expect(form.back).to be 98
    expect(form.step).to be 99
  end

  it "#has_journey?" do
    form = described_class.new(journey_id: "foo")
    expect(form).to have_journey

    form = described_class.new(journey_id: "none")
    expect(form).not_to have_journey

    form = described_class.new
    expect(form).not_to have_journey
  end

  it "#has_category?" do
    form = described_class.new(category_id: "foo")
    expect(form).to have_category

    form = described_class.new
    expect(form).not_to have_category
  end

  it "#forget_category!" do
    form = described_class.new(category_id: "foo")
    form.forget_category!
    expect(form).not_to have_category
  end

  it "#forget_journey!" do
    form = described_class.new(journey_id: "foo")
    form.forget_journey!
    expect(form).not_to have_journey
  end
end
