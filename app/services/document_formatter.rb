require "dry-initializer"
require "types"
require "pandoc-ruby"

# Document converter
#
class DocumentFormatter
  extend Dry::Initializer

  ReaderFormats = Types::Strict::Symbol.enum(:markdown)
  WriterFormats = Types::Strict::Symbol.enum(:docx, :pdf, :odt, :html)

  option :content, Types::Strict::String
  option :from, ReaderFormats
  option :to, WriterFormats

  # Return the converted document
  #
  # @return [String]
  def call
    PandocRuby.convert(content, "--strip-comments", from: from, to: to).to_s
  end
end
