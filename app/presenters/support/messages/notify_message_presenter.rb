module Support
  module Messages
    class NotifyMessagePresenter < ::Support::MessagePresenter
      def sent_by_email
        "Email"
      end

      def sent_by_name
        "Name"
      end

      def body_for_display(_)
      end

      def truncated_body_for_display(view_context)
        "yyy"
      end

      private

      def message_sent_at_date
        __getobj__.created_at
      end
    end
  end
end
