# frozen_string_literal: true

module Support
  class BasePresenter < SimpleDelegator
    def self.wrap_collection(collection)
      collection.map { |item| new(item) }
    end

    # @return [String]
    def created_at
      super.strftime(date_format)
    end

    # @return [String]
    def updated_at
      super.strftime(date_format)
    end

  private

    # @return [String] "26 November 2021"
    def date_format
      I18n.t("date.formats.presenter")
    end

    def short_date_time
      "%d-%m-%Y %H:%M"
    end

    def helpers
      ActionController::Base.helpers
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
