require "nokogiri"

module Support
  class EmailPresenter < ::Support::BasePresenter
    ALLOWED_HTML_TAGS = %w[
      img
      strong
      b
      br
      p
      hr
      ul
      ol
      li
      dt
      dd
      em
      details
      summary
      span
      div
    ].freeze

    # @return [String]
    def case_reference
      return nil if self.case.nil?

      Support::CasePresenter.new(self.case).ref
    end

    def case_org_name
      return nil if self.case.nil?

      Support::CasePresenter.new(self.case).organisation_name
    end

    def sent_by_email
      return nil if sender.nil?

      sender["address"]
    end

    def sent_by_name
      return nil if sender.nil?

      sender["name"]
    end

    def sent_at_formatted
      sent_at.strftime(date_format)
    end

    def body_for_display(view_context)
      # Do initial removal of links, and replace images with inline attachments
      new_body = body_with_links_removed(
        view_context, body_with_inline_attachments(view_context)
      )

      # remove comments
      new_body = new_body.gsub(/(<!--.*-->)/m, "")

      # Removal all html tags not defined in ALLOWED_HTML_TAGS list
      scrubber = Rails::Html::PermitScrubber.new
      scrubber.tags = ALLOWED_HTML_TAGS

      html_fragment = Loofah.fragment(new_body)
      html_fragment.scrub!(scrubber)

      # Return the cleaned body
      html_fragment.to_s
    end

  private

    def body_with_links_removed(_view_context, cleaned_body = body)
      html = Nokogiri::HTML(cleaned_body)

      html.xpath("//a[@href]").each do |link|
        if link["href"].starts_with?("javascript")
          link.remove
        else
          link.replace("#{link.text} (#{link['href']}) ")
        end
      end

      html.xpath("//body/node()").to_html
    end

    def body_with_inline_attachments(view_context, cleaned_body = body)
      html = Nokogiri::HTML(cleaned_body)

      inline_attachments = attachments.inline.index_by(&:content_id)

      inline_attachments.each do |content_id, attachment|
        html.xpath("//img[@src='cid:#{content_id}']").each do |img|
          img["src"] = view_context.support_document_download_path(attachment, type: attachment.class)
        end
      end

      html.xpath("//body/node()").to_html
    end

    def body_with_quotes_condensed(view_context, cleaned_body = body)
      html = Nokogiri::HTML(cleaned_body)

      # div.gmail_quote for gmail
      # hr tabindex -1 for some outlook
      #

      html.xpath("//body/node()").to_html
    end

    def date_format
      I18n.t("support.case.label.messages.table.date_format")
    end
  end
end
