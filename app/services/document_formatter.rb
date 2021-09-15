require "dry-initializer"
require "types"
require "pandoc-ruby"

# Convert Markdown into a document format
#
class DocumentFormatter
  extend Dry::Initializer

  option :markdown, Types::String
  option :format, Types::Symbol, default: proc { :docx }

  # Return the formatted document
  #
  # @param [Boolean]
  #
  def call(journey_complete:)
    unless journey_complete
      markdown.prepend(I18n.t("journey.specification.download.warning.incomplete"))
    end

    converter = PandocRuby.new(markdown, from: :markdown, to: format)
    converter.convert
  end
end
