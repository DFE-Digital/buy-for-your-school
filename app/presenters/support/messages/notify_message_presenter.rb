module Support
  module Messages
    class NotifyMessagePresenter < ::Support::MessagePresenter
      def sent_by_email
        "Email"
      end

      def sent_by_name
        "Name"
      end

      def body_for_display(_); end

      def truncated_body_for_display(_view_context)
        "yyy"
      end

      def is_read?
        true
      end

      def can_save_attachments?
        false
      end

      def can_mark_as_read?
        false
      end

      def attachments_for_display
        []
      end

      def render_actions(view_context)
        view_context.render("support/cases/message_threads/notify/actions", message: self)
      end

    private

      def message_sent_at_date
        __getobj__.created_at
      end
    end
  end
end
