require "dry-initializer"
require "types"

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
    remove_html_comments(liquid_template)
  end

  # Fill in answers and render specification in HTML
  #
  # @return [String]
  def html
    md = remove_html_comments(liquid_template.html_safe)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(md).html_safe
  end

private

  # Remove HTML comments (<!-- -->)
  #
  # These will occassionally not be ignored by the parser and must be removed here
  #
  # @param [String]
  def remove_html_comments(content)
    content.gsub(/\s*<!--.*?-->/, "")
  end

  # @return [Liquid::Template]
  def liquid_template
    Liquid::Template.parse(template, error_mode: :strict).render(answers)
  end
end
