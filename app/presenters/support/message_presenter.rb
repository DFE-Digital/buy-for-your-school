module Support
  class MessagePresenter < ::Support::BasePresenter
    def self.presenter_for(message_interaction)
      if message_interaction.email.present?
        Support::Messages::OutlookMessagePresenter.new(message_interaction.email)
      else
        Support::Messages::NotifyMessagePresenter.new(message_interaction)
      end
    end

    def sent_at_formatted
      message_sent_at_date.strftime(sent_at_date_format)
    end

  private

    def sent_at_date_format
      return "Yesterday at %H:%M" if message_sent_at_date.yesterday?
      return "Today at %H:%M" if message_sent_at_date.today?

      "%d %b %H:%M"
    end
  end
end
