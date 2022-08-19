module Support
  module Messages
    class NotifyMessagePresenter < ::Support::MessagePresenter
      def sent_by_email
        "Email"
      end

      def sent_by_name
        self.case.agent_name
      end

      def body_for_display(_)
        body.html_safe
      end

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

      def render_details(view_context)
        view_context.render("support/cases/message_threads/notify/details", message: self)
      end

      def templated_message?
        event_type.in?(%w[email_from_school email_to_school]) && additional_data.key?("email_template")
      end

      def case
        CasePresenter.new(super)
      end

      # @return [Hash]
      def additional_data
        super.each_with_object({}) do |(field, value), formatted_hash|
          case field
          when "email_template"
            formatted_hash["email_template"] = EmailTemplates.label_for(value)
          else
            formatted_hash[field] = value
          end
        end
      end

    private

      def message_sent_at_date
        __getobj__.created_at
      end
    end
  end
end
