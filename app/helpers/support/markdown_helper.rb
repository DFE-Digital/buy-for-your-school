module Support
  module MarkdownHelper
    def markdown_to_html(markdown_string)
      Markdown.new(markdown_string).to_html.html_safe
    end
  end
end
