require "rails_helper"

describe Navigators::BasicNavigator do
  subject(:navigator) { described_class.new }

  describe "#steps_forward" do
    it "returns 1" do
      form = double
      expect(navigator.steps_forward(form)).to eq(1)
    end
  end

  describe "#steps_backwards" do
    it "returns 1" do
      form = double
      expect(navigator.steps_backwards(form)).to eq(1)
    end
  end
end
