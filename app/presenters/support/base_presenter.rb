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

    # @return [String]
    def date_format
      "%e %B %Y at %H:%M"
    end

    def short_date_time
      "%d-%m-%Y %H:%M"
    end
  end
end
