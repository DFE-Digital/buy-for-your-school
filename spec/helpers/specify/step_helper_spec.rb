require "rails_helper"

RSpec.describe StepHelper, type: :helper do
  describe "#checkbox_options" do
    it "returns an array of OpenStruct objects" do
      options = %w[red blue]
      result = helper.checkbox_options(array_of_options: options)
      expect(result).to match([
        OpenStruct.new(id: "red", name: "red"),
        OpenStruct.new(id: "blue", name: "blue"),
      ])
    end
  end

  describe "#monkey_patch_form_object_with_further_information_field" do
    it "returns the modified form_object" do
      object = OpenStruct.new
      result = helper.monkey_patch_form_object_with_further_information_field(
        form_object: object,
        associated_choice: "foo",
      )
      expect(result).to eq(object)
    end

    it "adds a singleton method to the object" do
      object = OpenStruct.new
      result = helper.monkey_patch_form_object_with_further_information_field(
        form_object: object,
        associated_choice: "foo",
      )
      expect(result.foo_further_information).to eq(nil)
      expect(result.foo_further_information = "bar").to eql("bar")
    end

    context "when the object has a further_information field" do
      it "adds a singleton method with the same value as the return value" do
        object = OpenStruct.new(further_information: { "foo_further_information" => :bar })
        result = helper.monkey_patch_form_object_with_further_information_field(
          form_object: object,
          associated_choice: "foo",
        )
        expect(result.foo_further_information).to eq(:bar)
      end
    end
  end
end
