require "rails_helper"

RSpec.describe StepHelper, type: :helper do
  describe "#checkbox_options" do
    it "returns an array of OpenStruct objects" do
      options = ["red", "blue"]
      result = helper.checkbox_options(array_of_options: options)
      expect(result).to match([
        OpenStruct.new(id: "red", name: "Red"),
        OpenStruct.new(id: "blue", name: "Blue")
      ])
    end
  end
end
