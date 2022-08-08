require "nokogiri"

module Support
  module Messages
    class OutlookMessagePresenter < ::Support::MessagePresenter
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
        blockquote
        font
        table
        td
        tr
        th
        tbody
        thead
        tfooter
      ].freeze

      def case_reference
        return nil if self.case.nil?

        Support::CasePresenter.new(self.case).ref
      end

      def case_org_name
        return nil if self.case.nil?

        Support::CasePresenter.new(self.case).organisation_name
      end

      def sent_by_email
        sender&.[]("address")
      end

      def sent_by_name
        sender&.[]("name")
      end

      def body_for_display(view_context)
        # Do initial removal of links, and replace images with inline attachments
        new_body = body_with_links_removed(
          view_context, body_with_inline_attachments(view_context, unique_body)
        )

        # remove comments
        new_body = new_body.gsub(/(<!--.*-->)/m, "")

        # Removal all html tags not defined in ALLOWED_HTML_TAGS list
        scrubber = Rails::Html::PermitScrubber.new
        scrubber.tags = ALLOWED_HTML_TAGS

        html_fragment = Loofah.fragment(new_body)
        html_fragment.scrub!(scrubber)

        # Return the cleaned body
        html_fragment.to_s.html_safe
      end

      def truncated_body_for_display(view_context)
        view_context.strip_tags(body_for_display(view_context)).truncate(90)
      end

    private

      def body_with_links_removed(_view_context, cleaned_body)
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

      def body_with_inline_attachments(view_context, cleaned_body)
        html = Nokogiri::HTML(cleaned_body)

        inline_attachments = attachments.inline.index_by(&:content_id)

        inline_attachments.each do |content_id, attachment|
          html.xpath("//img[@src='cid:#{content_id}']").each do |img|
            img["src"] = view_context.support_document_download_path(attachment, type: attachment.class)
          end
        end

        html.xpath("//body/node()").to_html
      end

      def message_sent_at_date
        sent_at
      end
    end
  end
end
