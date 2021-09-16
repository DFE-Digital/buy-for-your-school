require "dry-initializer"
require "types"

# Parses Liquid templates and renders them
#
class LiquidParser
  extend Dry::Initializer

  option :template, Types::String
  option :answers, Types::Hash
  option :draft_msg, Types::String, optional: true

  # Fill in answers and render specification
  #
  # @param draft [Boolean] - if true, prepends `draft_msg` to the template
  #
  # @return [String]
  def render(draft: true)
    temp = template.dup
    temp.prepend("#{draft_msg}\n\n") if draft
    Liquid::Template.parse(temp, error_mode: :strict).render(answers)
  end
end
