module Support
  class EmailPresenter < ::Support::BasePresenter
    # @return [String]
    def case_reference
      return nil if self.case.nil?

      Support::CasePresenter.new(self.case).ref
    end

    def case_org_name
      return nil if self.case.nil?

      Support::CasePresenter.new(self.case).org_name
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
      sent_at.strftime(short_date_time)
    end

    def body_with_inline_attachments(view_context)
      inline_attachments = attachments.inline.index_by(&:content_id)

      body.tap do |body_with_attachments|
        inline_attachments.each do |content_id, attachment|
          body_with_attachments.gsub!("cid:#{content_id}", view_context.support_document_download_path(attachment, type: attachment.class))
        end
      end
    end
  end
end
