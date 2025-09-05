class Email::TemplateParser
  def initialize(variables: {})
    @variables = {
      "caseworker_full_name" => Current.actor.try(:full_name),
      "case_creator_full_name" => "{{case_creator_full_name}}",
      "case_reference_number" => "{{case_reference_number}}",
      "organisation_name" => "{{organisation_name}}",
      "sub_category" => "{{sub_category}}",
      "unique_case_specific_link" => "{{unique_case_specific_link}}",
      "evaluation_due_date" => "{{evaluation_due_date}}",
      "gas_and_or_electricity_contract_start_dates" => "{{gas_and_or_electricity_contract_start_dates}}",
      "case_creator_first_name" => "{{case_creator_first_name}}",
      "electricity_contract_end_date" => "{{electricity_contract_end_date}}",
      "billing_payment_terms" => "{{billing_payment_terms}}",
    }.merge(variables)
  end

  def parse(template)
    Liquid::Template.parse(template, error_mode: :strict).render(@variables)
  end
end
