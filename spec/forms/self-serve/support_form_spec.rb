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

  describe "#navigate" do
    context "when moving backwards through the steps" do
      context "when step is currently 1 and user has no journeys" do
        it "remains on step 1 (cannot be 0)" do
          form = described_class.new(direction: :backwards, step: 1)
          form.navigate(user_journeys: [])

          expect(form.step).to be(1)
        end
      end

      context "when step is currently 2 and user has some journeys" do
        it "moves back to step 1" do
          form = described_class.new(direction: :backwards, step: 1, journey_id: "123")
          form.navigate(user_journeys: [double])

          expect(form.step).to be(1)
        end
      end

      context "when step is currently 2 and user has no journeys" do
        it "moves back to step 1" do
          form = described_class.new(direction: :backwards, step: 1)
          form.navigate(user_journeys: [])

          expect(form.step).to be(1)
        end
      end

      context "when step is currently 3 and user has some journeys" do
        it "moves back to step 2" do
          form = described_class.new(direction: :backwards, step: 3, journey_id: "123")
          form.navigate(user_journeys: [double])

          expect(form.step).to be(2)
        end
      end

      context "when step is currently 3 and user has no journeys" do
        it "moves back to step 1" do
          form = described_class.new(direction: :backwards, step: 3)
          form.navigate(user_journeys: [])

          expect(form.step).to be(1)
        end
      end

      context "when step is currently 4 and user has some journeys" do
        it "moves back to step 2" do
          form = described_class.new(direction: :backwards, step: 4, journey_id: "123")
          form.navigate(user_journeys: [double])

          expect(form.step).to be(2)
        end
      end

      context "when step is currently 4 and user has no journeys" do
        it "moves back to step 3" do
          form = described_class.new(direction: :backwards, step: 4)
          form.navigate(user_journeys: [])

          expect(form.step).to be(3)
        end
      end
    end

    context "when moving forwards through the steps" do
      context "when step is currently 1 and user has no journeys" do
        it "moves to step 3" do
          form = described_class.new(direction: :forwards, step: 1)
          form.navigate(user_journeys: [])

          expect(form.step).to be(3)
        end
      end

      context "when step is currently 1 and user has journeys" do
        it "moves to step 2" do
          form = described_class.new(direction: :forwards, step: 1)
          form.navigate(user_journeys: [double])

          expect(form.step).to be(2)
        end
      end

      context "when step is currently 2 and user has journeys" do
        it "moves to step 4" do
          form = described_class.new(direction: :forwards, step: 2, journey_id: "123")
          form.navigate(user_journeys: [double])

          expect(form.step).to be(4)
        end
      end

      context "when step is currently 2 and user has no journeys" do
        it "moves to step 3" do
          form = described_class.new(direction: :forwards, step: 2)
          form.navigate(user_journeys: [])

          expect(form.step).to be(3)
        end
      end

      context "when step is currently 3" do
        it "moves to step 4" do
          form = described_class.new(direction: :forwards, step: 3)
          form.navigate(user_journeys: [])

          expect(form.step).to be(4)
        end
      end
    end
  end
end
