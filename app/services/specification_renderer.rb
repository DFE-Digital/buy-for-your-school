require "dry-initializer"
require "types"

# Renders a specification in a chosen format
#
class SpecificationRenderer
  extend Dry::Initializer

  option :journey, Types.Instance(Journey) | Types.Instance(JourneyPresenter)
  option :from, Types::Strict::Symbol, default: proc { :markdown }
  option :to, Types::Strict::Symbol, default: proc { :docx }
  option :draft_msg, Types::Strict::String, default: proc { I18n.t("journey.specification.draft") }

  # @param draft (optional) [Boolean] - if true, prepends `draft_msg` to the spec (overrides journey completeness check)
  #
  # return [String]
  def call(draft: nil)
    is_draft = draft.nil? ? !journey.all_tasks_completed? : draft

    template = LiquidParser.new(
      template: journey.category.liquid_template,
      answers: answers,
    ).call

    template.prepend("#{draft_msg}\n\n") if is_draft

    document_formatter(template)
  end

private

  # Return the answers in this journey
  #
  # @return [Hash]
  def answers
    GetAnswersForSteps.new(visible_steps: journey.steps).call
  end

  # Convert the template
  #
  # @param [String] template
  #
  # @return [String]
  def document_formatter(template)
    DocumentFormatter.new(content: template, from: from, to: to).call
  end
end
