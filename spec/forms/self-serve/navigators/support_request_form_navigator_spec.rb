require "rails_helper"

describe Navigators::SupportRequestFormNavigator do
  subject(:navigator) { described_class.new(user_journeys: user_journeys) }

  let(:user_journeys) { [double] }
  let(:form_has_journey) { false }
  let(:step) { 1 }
  let(:form) { instance_double("SupportForm", step: step, has_journey?: form_has_journey) }

  describe "#steps_forward" do
    let(:result) { navigator.steps_forward(form) }

    it "returns 1 step by default" do
      expect(result).to eq(1)
    end

    context "when form step is currently 1" do
      let(:step) { 1 }

      context "when user_journeys has none" do
        let(:user_journeys) { [] }

        it "returns 2 steps" do
          expect(result).to eq(2)
        end
      end

      it "returns 1 step" do
        expect(result).to eq(1)
      end
    end

    context "when form step is currently 2" do
      let(:step) { 2 }

      context "when form has journey already selected" do
        let(:form_has_journey) { true }

        it "returns 2 steps" do
          expect(result).to eq(2)
        end
      end

      it "returns 1 step" do
        expect(result).to eq(1)
      end
    end
  end

  describe "#move_backwards" do
    let(:result) { navigator.steps_backwards(form) }

    it "returns 1 step by default" do
      expect(result).to eq(1)
    end

    context "when form step is currently 3" do
      let(:step) { 3 }

      context "when user_journeys has none" do
        let(:user_journeys) { [] }

        it "returns 2 steps" do
          expect(result).to eq(2)
        end
      end

      it "returns 1 step" do
        expect(result).to eq(1)
      end
    end

    context "when form step is currently 4" do
      let(:step) { 4 }

      context "when form has journey already selected" do
        let(:form_has_journey) { true }

        it "returns 2 steps" do
          expect(result).to eq(2)
        end
      end

      it "returns 1 step" do
        expect(result).to eq(1)
      end
    end
  end
end
