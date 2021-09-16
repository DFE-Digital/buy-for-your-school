require "dry-initializer"
require "types"
require "pandoc-ruby"

# Document converter
#
class DocumentFormatter
  extend Dry::Initializer

  ReaderFormats = Types::Symbol.enum(:markdown)
  WriterFormats = Types::Symbol.enum(:docx, :pdf, :odt, :html)

  option :content, Types::String
  option :from, ReaderFormats, default: proc { :markdown }
  option :to, WriterFormats, default: proc { :docx }

  # Return the converted document
  #
  # @return [String]
  def call
    PandocRuby.convert(content, from: from, to: to)
  end
end
