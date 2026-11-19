# frozen_string_literal: true

# GHBS-specific extension for accessible-autocomplete. The text input is
# rendered by GOV.UK Form Builder so labels, hints and validation errors follow
# the same conventions as the rest of the form.
module GOVUKDesignSystemFormBuilderAutocomplete
  def govuk_autocomplete_field(attribute_name, query_url:, value_field:, label:, element_id:, element_name: nil,
                               container_id: nil, container_data: {}, default_value: nil, hidden_fields: {}, template_suggestion: nil,
                               template_field: nil, templates: nil, hidden_field_html: {}, **options)
    data = (options.delete(:data) || {}).merge(
      component: "autocomplete",
      autocomplete_element_id: element_id,
      autocomplete_element_name: element_name || field_name(attribute_name),
      autocomplete_container_id: container_id,
      autocomplete_container_data: container_data.to_json,
      autocomplete_query_url: query_url,
      autocomplete_template_input: value_field,
      autocomplete_default_value: default_value,
      autocomplete_hidden_fields: hidden_fields.to_json,
      autocomplete_template_suggestion: template_suggestion,
      autocomplete_template_field: template_field,
      autocomplete_templates: templates&.to_json,
    ).compact

    input_options = options.merge(
      id: element_id,
      name: element_name || field_name(attribute_name),
      value: default_value,
      data:,
    )
    field_label = label.is_a?(Hash) ? label.merge(for: element_id) : label

    @template.safe_join([
      govuk_text_field(attribute_name, label: field_label, **input_options),
      hidden_fields.map do |name, key_or_key_and_default|
        default = key_or_key_and_default.is_a?(Array) ? key_or_key_and_default[1] : nil
        @template.hidden_field_tag(name, default, hidden_field_html)
      end,
    ].flatten)
  end

private

  def field_name(attribute_name)
    "#{object_name}[#{attribute_name}]"
  end
end

GOVUKDesignSystemFormBuilder::FormBuilder.include(GOVUKDesignSystemFormBuilderAutocomplete)
