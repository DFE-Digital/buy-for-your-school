class Email::TemplateParser
  def initialize(variables: {})
    @variables = {
      "caseworker_full_name" => Current.actor.try(:full_name),
    }.merge(variables)
  end

  def parse(template)
    Liquid::Template.parse(template, error_mode: :strict).render(@variables)
  end
end
