class Email::TemplateParser
  def initialize(variables: {})
    @variables = {
      "caseworker_full_name" => Current.actor.try(:full_name),
      "case_creator_full_name" => "{{case_creator_full_name}}",
      "case_creator_full_name1" => "{{case_creator_full_name1}}",
      "case_reference_number" => "{{case_reference_number}}",
      "organisation_name" => "{{organisation_name}}",
      "sub_category" => "{{sub_category}}",
      "unique_case_specific_link" => "{{unique_case_specific_link}}",
      "gas_and_or_electricity_contract_start_dates" => "{{gas_and_or_electricity_contract_start_dates}}",
    }.merge(variables)
  end

  def parse(template)
    Liquid::Template.parse(template, error_mode: :strict).render(@variables)
  end
end
