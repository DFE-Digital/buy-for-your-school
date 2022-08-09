module Support
  class MessageThreadPresenter < BasePresenter
    # @return [String]
    def recipients
      super.pluck("name").filter { |name| name != ENV["MS_GRAPH_SHARED_MAILBOX_NAME"] }.join(", ")
    end

    # @return [String]
    def last_updated
      super.strftime(date_format)
    end

    def messages
      super.map { |message| Support::Messages::OutlookMessagePresenter.new(message) }
    end

    def subject
      messages.first.subject
    end

  private

    def date_format
      I18n.t("support.case.label.messages.table.date_format")
    end
  end
end
