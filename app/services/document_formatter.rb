require "dry-initializer"
require "types"
require "pandoc-ruby"

# Convert Markdown into a document format
#
class DocumentFormatter
  extend Dry::Initializer

  Formats = Types::Symbol.enum(:docx)

  option :markdown, Types::String
  option :format, Formats, default: proc { :docx }

  # Return the formatted document
  #
  # @param draft [Boolean]
  #
  def call(draft: true)
    markdown.prepend(I18n.t("journey.specification.download.warning.incomplete")) if draft

    PandocRuby.convert(markdown, from: :markdown, to: format)
  end
end
