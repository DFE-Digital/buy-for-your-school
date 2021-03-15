class SpecificationRenderer
  def initialize(template:, answers:)
    @template = Liquid::Template.parse(
      template, error_mode: :strict
    )
    @answers = answers
  end

  def to_html
    @template.render(@answers).html_safe
  end
end
