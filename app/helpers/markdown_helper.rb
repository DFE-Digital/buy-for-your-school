# TODO: consider deprecating use of this class in favour of Support::Markdown - this was introduced
# from FABS codebase. Contentful content formatting and markdown -> HTML conversion should be standardised
module MarkdownHelper
  ALLOWED_TAGS = %w[p h1 h2 h3 h4 h5 h6 a ul ol li strong em br img table thead tbody tr th td caption blockquote div].freeze
  ALLOWED_ATTRIBUTES = %w[href src alt target rel class id style].freeze
  # Link text wrapped in "==" (e.g. "[==Start now==](/url)") renders as a GOV.UK start button
  CTA_BUTTON_PATTERN = /\A==(.+)==\z/m

  def render_markdown_to_html(markdown_content)
    return "" if markdown_content.blank?

    html = Kramdown::Document.new(markdown_content).to_html
    html = sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)

    return html.html_safe unless html.match?(/href|<p\b|<h2\b|<img\b|<table\b/)

    doc = Nokogiri::HTML.fragment(html)

    doc = update_class(doc, "h2", "govuk-heading-m")
    doc = update_class(doc, "p", "govuk-body")

    doc.css("a[href]").each do |link|
      external_link_attributes(link["href"]).each do |key, value|
        link[key] = value
      end

      match = link.text.strip.match(CTA_BUTTON_PATTERN)
      next unless match

      link.content = match[1].strip
      link["class"] = [link["class"], "govuk-button govuk-button--start"].compact.join(" ")
    end

    doc = update_class(doc, "a[href]:not(.govuk-button)", "govuk-link")
    doc = update_class(doc, "img", "govuk-!-width-full")

    doc = update_class(doc, "table", "govuk-table")
    doc = update_class(doc, "thead", "govuk-table__head")
    doc = update_class(doc, "tbody", "govuk-table__body")
    doc = update_class(doc, "tr", "govuk-table__row")
    doc = update_class(doc, "th", "govuk-table__header")
    doc = update_class(doc, "td", "govuk-table__cell")

    doc.css('th[style="text-align:right;"]').each do |th|
      th["class"] = [th["class"], "govuk-table__header--numeric"].compact.join(" ")
      th.remove_attribute("style")
    end

    doc.css('td[style="text-align:right;"]').each do |td|
      td["class"] = [td["class"], "govuk-table__cell--numeric"].compact.join(" ")
      td.remove_attribute("style")
    end

    doc.css("th").each do |th|
      th["scope"] ||= "col"
    end

    doc.css("blockquote").each do |blockquote|
      inset_text = Nokogiri::XML::Node.new("div", doc)
      inset_text["class"] = "govuk-inset-text"

      inset_text.content = blockquote.text.strip

      blockquote.replace(inset_text)
    end

    doc.to_html.html_safe
  end

  def update_class(doc, tag_type, class_name)
    return doc unless doc.at_css(tag_type)

    doc.css(tag_type).each do |tag|
      unless tag["class"] && tag["class"].include?(class_name)
        tag["class"] = [tag["class"], class_name].compact.join(" ")
      end
    end

    doc
  end
end
