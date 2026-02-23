# frozen_string_literal: true

require_relative "contentful"

module I18n
  module Backend
    class GhbsContentful < Contentful
      def initialize(namespaces:, fallback_backend:)
        super()
        @namespaces = Array(namespaces).map(&:to_s)
        @fallback_backend = fallback_backend
      end

      def translate(locale, key, options = EMPTY_HASH)
        if handles?(locale, key, options)
          super
        else
          throw(:exception, I18n::MissingTranslationData.new(locale, key, options))
        end
      rescue I18n::MissingTranslationData => e
        throw(:exception, e)
      end

      def store_translations(locale, data, options = {})
        @fallback_backend.store_translations(locale, data, options)
      end

    private

      def handles?(locale, key, options)
        normalized = I18n.normalize_keys(locale, key, options[:scope], options[:separator])
        top_level = normalized[1]

        return false unless top_level

        @namespaces.include?(top_level.to_s)
      end
    end
  end
end
