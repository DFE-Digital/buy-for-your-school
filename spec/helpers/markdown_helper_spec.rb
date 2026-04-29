require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#render_markdown_to_html" do
    it "adds external link attributes to links" do
      markdown = "[Internal](/internal) [External](https://example.com)"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<a href="/internal" class="govuk-link">Internal</a>')
      expect(html).to include('<a href="https://example.com" target="_blank" rel="noopener noreferrer" class="govuk-link">External</a>')
    end

    it "add the correct css class for h2 and paragraph tags" do
      markdown = "## This a heading\nThis is a random paragraph"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<h2 id="this-a-heading" class="govuk-heading-m">This a heading</h2>')
      expect(html).to include('<p class="govuk-body">This is a random paragraph</p>')
    end

    it "add no css class for h1 heading" do
      markdown = "# H1 heading"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<h1 id="h1-heading">H1 heading</h1>')
    end

    describe "sanitization" do
      it "strips script tags" do
        markdown = "<script>alert('xss')</script>"
        html = helper.render_markdown_to_html(markdown)
        expect(html).not_to include("<script")
        expect(html).not_to include("</script>")
      end

      it "strips iframe tags" do
        markdown = "<iframe src='https://evil.com'></iframe>"
        html = helper.render_markdown_to_html(markdown)
        expect(html).not_to include("<iframe")
      end

      it "strips style tags" do
        markdown = "<style>body { display: none; }</style>"
        html = helper.render_markdown_to_html(markdown)
        expect(html).not_to include("<style>")
      end

      it "strips event handler attributes" do
        markdown = "<a href='/safe' onclick='alert(1)'>Click</a>"
        html = helper.render_markdown_to_html(markdown)
        expect(html).not_to include("onclick")
        expect(html).to include('href="/safe"')
      end

      it "strips onerror attributes from images" do
        markdown = "<img src='x' onerror='alert(1)'>"
        html = helper.render_markdown_to_html(markdown)
        expect(html).not_to include("onerror")
      end

      it "allows safe tags and attributes" do
        markdown = "<a href='https://gov.uk' title='Gov'>Link</a>"
        html = helper.render_markdown_to_html(markdown)
        expect(html).to include('href="https://gov.uk"')
        expect(html).not_to include("title")
      end
    end
  end
end
