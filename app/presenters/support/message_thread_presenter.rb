module Support
  class MessageThreadPresenter < BasePresenter
    # @return [String]
    def recipients
      super.pluck("name").join(", ")
    end

    # @return [String]
    def last_updated
      super.strftime(date_format)
    end

  private

    def date_format
      I18n.t("support.case.label.messages.table.date_format")
    end
  end
end
