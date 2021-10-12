require "rails_helper"

describe MultiStepForm do
  subject(:form) { described_class.new }

  describe "#steps_to_move_forwards" do
    it "returns 1 by default" do
      expect(form.steps_to_move_forwards).to eq(1)
    end
  end

  describe "#steps_to_move_backwards" do
    it "returns 1 by default" do
      expect(form.steps_to_move_backwards).to eq(1)
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
        the_form = described_class.new(total_steps: 10, step: 10)

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
        the_form = described_class.new(total_steps: 10, step: 1)

        the_form.move_backwards!(1)

        expect(the_form.step).to be(1)
      end
    end
  end
end
