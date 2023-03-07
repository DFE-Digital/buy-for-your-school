module Support
  class MessagePresenter < ::Support::BasePresenter
    include DateHelper

    def self.presenter_for(message_interaction)
      if message_interaction.email.present?
        Support::Messages::OutlookMessagePresenter.new(message_interaction.email)
      else
        Support::Messages::NotifyMessagePresenter.new(message_interaction)
      end
    end

    def sent_at_formatted
      return message_sent_at_date.strftime("Yesterday at %H:%M") if message_sent_at_date.yesterday?
      return message_sent_at_date.strftime("Today at %H:%M") if message_sent_at_date.today?

      short_date_format(message_sent_at_date)
    end
  end
end
