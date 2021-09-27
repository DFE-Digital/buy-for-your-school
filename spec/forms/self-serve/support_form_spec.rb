RSpec.describe SupportForm, type: :model do
  let(:journey) { create(:journey) }
  let(:category) { create(:category) }
  let(:user) { create(:user) }

  let(:phone_number) { "0151 000 0000" }
  let(:message) { "My support message" }

  context "with step 1" do
    subject(:current_step) do
      SupportForm::Step1.new(
        step: 1,
        phone_number: phone_number,
      )
    end

    it { is_expected.not_to be_last_step }

    context "with a phone number" do
      it { is_expected.to be_valid }

      it "increments the step counter" do
        expect(current_step.save).to eq 2
      end
    end

    context "without a phone number" do
      let(:phone_number) { nil }

      it { is_expected.not_to be_valid }

      it "does not save" do
        expect(current_step.save).to be false
      end
    end

    describe "#next_step" do
      it "increments the step counter" do
        expect(current_step.next_step).to eq 2
      end
    end
  end

  context "with step 2" do
    subject(:current_step) do
      SupportForm::Step2.new(
        step: 2,
        phone_number: phone_number,
        journey_id: journey&.id,
      )
    end

    it { is_expected.not_to be_last_step }

    context "with a journey" do
      it { is_expected.to be_valid }

      it "increments the step counter" do
        expect(current_step.save).to eq 3
      end
    end

    context "without a journey" do
      let(:journey) { nil }

      it { is_expected.not_to be_valid }

      it "does not save" do
        expect(current_step.save).to be false
      end
    end

    describe "#next_step" do
      it "increments the step counter" do
        expect(current_step.next_step).to eq 3
      end
    end
  end

  context "with step 3" do
    subject(:current_step) do
      SupportForm::Step3.new(
        step: 3,
        phone_number: phone_number,
        journey_id: journey.id,
        category_id: category&.id,
      )
    end

    it { is_expected.not_to be_last_step }

    context "with a category" do
      it { is_expected.to be_valid }

      it "increments the step counter" do
        expect(current_step.save).to eq 4
      end
    end

    context "without a category" do
      let(:category) { nil }

      it { is_expected.not_to be_valid }

      it "does not save" do
        expect(current_step.save).to eq false
      end
    end

    describe "#next_step" do
      it "increments the step counter" do
        expect(current_step.next_step).to eq 4
      end
    end
  end

  context "with step 4 (last)" do
    subject(:current_step) do
      SupportForm::Step4.new(
        step: 4,
        phone_number: phone_number,
        journey_id: journey.id,
        category_id: category.id,
        message: message,
        user: user,
      )
    end

    it { is_expected.to be_last_step }

    context "with a user and message" do
      it { is_expected.to be_valid }
    end

    context "without a user" do
      let(:user) { nil }

      it { is_expected.not_to be_valid }
    end

    context "without a message" do
      let(:message) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "#next_step" do
      it do
        expect(current_step.next_step).to eq 5
      end
    end
  end
end
