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

    it "adds the correct css class for h1 heading" do
      markdown = "# H1 heading"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<h1 id="h1-heading" class="govuk-heading-l">H1 heading</h1>')
    end

    it "adds the correct css class for h3 heading" do
      markdown = "### H3 heading"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<h3 id="h3-heading" class="govuk-heading-s">H3 heading</h3>')
    end

    it "adds the correct css class for a section break" do
      markdown = "---"
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<hr class="govuk-section-break govuk-section-break--m govuk-section-break--visible">')
    end

    it "adds the correct css class for an unordered list" do
      markdown = <<~MD
        - bullet 1
        - bullet 2
        - bullet 3
      MD
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<ul class="govuk-list govuk-list--bullet">')
    end

    it "adds the correct css class for an ordered list" do
      markdown = <<~MD
        1. first point
        2. second point
        3. third point
      MD
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<ol class="govuk-list govuk-list--number">')
    end

    it "adds the correct css class for an ordered list with a break inbetween numbers" do
      markdown = <<~MD
        1. First item
        2. Second item

        ## Heading

        <ol start="3">
        <li>Third item</li>
        <li>Fourth item</li>
        </ol>
      MD
      html = helper.render_markdown_to_html(markdown)
      expect(html).to include('<ol start="3" class="govuk-list govuk-list--number">')
    end

    it "renders markdown tables with GOV.UK table classes" do
      markdown = <<~MD
        | Scenario | Status |
        | ------- | ---- |
        | DfE approved energy | Compliant |
        | Non-DfE approved energy | Non-compliant |
      MD

      html = helper.render_markdown_to_html(markdown)

      expect(html).to include('class="govuk-table"')
      expect(html).to include('class="govuk-table__head"')
      expect(html).to include('class="govuk-table__body"')
      expect(html).to include('class="govuk-table__row"')
      expect(html).to include('class="govuk-table__header"')
      expect(html).to include('class="govuk-table__cell"')

      expect(html).to include("Scenario")
      expect(html).to include("Status")
      expect(html).to include("DfE approved energy")
      expect(html).to include("Compliant")
    end

    it "adds GOV.UK numeric classes to right-aligned columns" do
      markdown = <<~MD
        | Scenario | Quote |
        | ------- | ---: |
        | DfE approved energy | £100 |
        | Non-DfE approved energy | £1000 |
      MD

      html = helper.render_markdown_to_html(markdown)

      expect(html).to include("govuk-table__header--numeric")
      expect(html).to include("govuk-table__cell--numeric")
    end

    it "renders blockquotes as GOV.UK inset text" do
      markdown = "> Important buying information"

      html = helper.render_markdown_to_html(markdown)

      expect(html).to include('class="govuk-inset-text"')
      expect(html).not_to include("<blockquote>")
      expect(html).not_to include("<p>")
      expect(html).to include("Important buying information")
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
