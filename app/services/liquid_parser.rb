require "dry-initializer"
require "types"

# Parses Liquid templates and renders them
#
class LiquidParser
  extend Dry::Initializer

  option :template, Types::String
  option :answers, Types::Hash

  # Fill in answers and render specification
  #
  # @return [String]
  def render
    Liquid::Template.parse(template, error_mode: :strict).render(answers)
  end
end
