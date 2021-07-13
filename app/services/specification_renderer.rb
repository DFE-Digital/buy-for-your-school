# Parse Liquid templates and render HTML
#
class SpecificationRenderer
  # @param template [String]
  # @param answers [Hash] `answer_extended-checkboxes-question`
  #
  def initialize(template:, answers:)
    @template = Liquid::Template.parse(template, error_mode: :strict)
    @answers = answers
  end

  def to_html
    @template.render(@answers).html_safe
  end

  def to_document_html(journey_complete:)
    document_html = @template.render(@answers)
    unless journey_complete
      document_html.prepend(I18n.t("journey.specification.download.warning.incomplete"))
    end
    document_html
  end
end
