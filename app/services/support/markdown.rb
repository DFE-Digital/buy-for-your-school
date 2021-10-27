require "pandoc-ruby"

module Support
  class Markdown
    def initialize(markdown_string)
      @markdown_string = markdown_string
    end

    def to_html
      PandocRuby.convert(@markdown_string, "--strip-comments", from: :markdown, to: :html)
    end
  end
end
