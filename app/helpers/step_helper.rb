# frozen_string_literal: true

module StepHelper
  # Constructs OpenStruct objects for checkbox form elements.
  #
  # @param [Array<String>] array_of_options
  #
  # @return [Array<OpenStruct>]
  def checkbox_options(array_of_options:)
    array_of_options.map do |option|
      OpenStruct.new(id: option.downcase, name: option)
    end
  end

  # Modifies the form object when displayed to the user.
  #
  # Dynamically adds attributes to the object so that the form object can work with unique further information fields.
  #
  # @return [Object]
  def monkey_patch_form_object_with_further_information_field(
    form_object:,
    associated_choice:
  )
    existing_further_information = form_object&.further_information&.fetch(
      "#{associated_choice}_further_information", nil
    )

    form_object.define_singleton_method("#{associated_choice}_further_information") do
      existing_further_information
    end

    form_object
  end
end
