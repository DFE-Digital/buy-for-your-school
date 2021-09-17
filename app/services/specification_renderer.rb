require "dry-initializer"
require "types"

# Renders a specification in a chosen format
#
class SpecificationRenderer
  extend Dry::Initializer

  option :journey, Types.Instance(Journey) | Types.Instance(JourneyPresenter)
  option :from, Types::Symbol, default: proc { :markdown }
  option :to, Types::Symbol, default: proc { :docx }
  option :draft_msg, Types::String, default: proc { I18n.t("journey.specification.warning") }

  # @param draft [Boolean] - if true, prepends `draft_msg` to the spec
  #
  # return [String]
  def call(draft: true)
    template = LiquidParser.new(
      template: journey&.category&.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: journey&.steps).call,
    ).render

    template.prepend("#{draft_msg}\n\n") if draft

    DocumentFormatter.new(content: template, from: from, to: to).call
  end
end
