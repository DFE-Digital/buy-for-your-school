require "dry-initializer"
require "types"
require "pandoc-ruby"

# Parse Liquid templates and render Markdown
#
class SpecificationRenderer
  extend Dry::Initializer

  option :template, Types::String
  option :answers, Types::Hash

  # Fill in answers and render specification in Markdown
  #
  # @return [String]
  def markdown
    Liquid::Template.parse(template, error_mode: :strict).render(answers)
  end

  # Render the Markdown specification in HTML
  #
  # @return [String]
  def html
    PandocRuby.convert(markdown.html_safe, from: :markdown, to: :html).html_safe
  end
end
