require "dry-initializer"
require "types"
require "pandoc-ruby"

# Document converter
#
class DocumentFormatter
  extend Dry::Initializer

  ReaderFormats = Types::Strict::Symbol.enum(:markdown)
  WriterFormats = Types::Strict::Symbol.enum(:docx, :pdf, :odt, :html)

  # @!attribute [r] content
  # @return [String]
  option :content, Types::Strict::String
  # @!attribute [r] from
  # @return [Symbol] markdown only
  option :from, ReaderFormats
  # @!attribute [r] to
  # @return [Symbol] docx, pdf, odt, or html
  option :to, WriterFormats

  # Return the converted document.
  # HTML comments are stripped out.
  #
  # @return [String]
  def call
    PandocRuby.convert(content, "--strip-comments", from: from, to: to)
  end
end
