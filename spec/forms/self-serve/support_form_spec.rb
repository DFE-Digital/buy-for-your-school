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

  describe "#move_forwards!" do
    context "when no amount of steps given" do
      it "increments step by 1" do
        form.move_forwards!
        expect(form.step).to be(2)

        form.move_forwards!
        expect(form.step).to be(3)
      end
    end

    context "when given a number of steps" do
      it "increments step by that number" do
        form.move_forwards!(2)
        expect(form.step).to be(3)
      end
    end

    context "when moving beyond the defined last step" do
      it "remains on the last step without going past it" do
        navigator = Navigators::BasicNavigator.new(last_step: 10)
        the_form = described_class.new(step: 10, navigator: navigator)

        the_form.move_forwards!(1)

        expect(the_form.step).to be(10)
      end
    end
  end

  describe "#move_backwards!" do
    context "when no amount of steps given" do
      it "decrements step by 1" do
        the_form = described_class.new(step: 10)

        the_form.move_backwards!
        expect(the_form.step).to be(9)

        the_form.move_backwards!
        expect(the_form.step).to be(8)
      end
    end

    context "when given a number of steps" do
      it "decrements step by that number" do
        the_form = described_class.new(step: 10)

        the_form.move_backwards!(2)

        expect(the_form.step).to be(8)
      end
    end

    context "when moving beyond the defined last step" do
      it "remains on the first step without going past it" do
        navigator = Navigators::BasicNavigator.new(first_step: 1, last_step: 10)
        the_form = described_class.new(step: 1, navigator: navigator)

        the_form.move_backwards!(1)

        expect(the_form.step).to be(1)
      end
    end
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
