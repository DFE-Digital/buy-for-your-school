require_relative "../utils"

module I18n
  module Backend
    class Contentful
      include Base
      include Flatten

      CACHE_KEY = "contentful_translations".freeze
      CACHE_EXPIRY = ENV.fetch("RAILS_CACHE_EXPIRY_IN_SECONDS", "86400").to_i

      def initialize
        @translations = Concurrent::Hash.new
        ::ContentfulClient.configure(
          space: ENV.fetch("CONTENTFUL_SPACE_ID") { "FAKE_SPACE_ID" },
          access_token: ENV.fetch("CONTENTFUL_ACCESS_TOKEN") { "FAKE_API_KEY" },
          environment: ENV.fetch("CONTENTFUL_ENVIRONMENT", "master"),
        )
        load_translations
      end

      def translations
        @translations || load_translations
      end

      def available_locales
        @available_locales || set_available_locales
      end

      def reload!
        load_translations
        true
      end

      def translate(locale, key, options = EMPTY_HASH)
        # Handling date format lookups
        if key.to_s == "date.formats.standard" || (key.to_s == "formats.standard" && options[:scope] == %w[date])
          date_format = translations[:'en.date.formats.standard']&.delete_prefix('"')&.delete_suffix('"')
          Rails.logger.debug "Found date format: #{date_format}" if date_format.present?
          return date_format if date_format.present?
        end

        # Handling relative keys
        if key.to_s.start_with?(".")
          scope = Array(options[:scope])
          if scope.first.to_s.include?("/")
            view_path = scope.first.split("/")
            key = "#{view_path.last}#{key}"
            options[:scope] = view_path[0..-2]
          end
        end

        # Normalizing the key path
        split_keys = I18n.normalize_keys(locale, key, options[:scope], options[:separator])

        # Lookup in order: direct key, locale, and fallback
        lookup_hierarchy = [
          -> { interpolate_if_string(locale, translations[key.to_sym], options) },
          -> { interpolate_if_string(locale, translations.dig(locale, split_keys[1..].join(".").to_sym), options) },
          -> { interpolate_if_string(locale, translations[split_keys.join(".").to_sym], options) },
        ]

        lookup_hierarchy.each do |lookup|
          value = lookup.call
          return value if value.present?
        end

        # Fallback to default locale
        if options[:fallback] && locale != I18n.default_locale
          return translate(I18n.default_locale, key, options.merge(fallback: false))
        end

        Rails.logger.debug "No translation found for #{key}"
        nil
      end

    private

      def load_translations
        # Fetch from Redis first
        cached_translations = Rails.cache.read(CACHE_KEY)

        if cached_translations.nil?
          # If not in cache, fetch from Contentful
          entries = ::ContentfulClient.entries(
            content_type: "translation",
            limit: 1000,
          )

          cached_translations = I18n::Utils.unflatten_translations(entries)

          Rails.cache.write(CACHE_KEY, cached_translations, expires_in: CACHE_EXPIRY)
        end

        @translations = I18n::Utils.deep_merge!(@translations, cached_translations)
        set_available_locales

        @translations
      end

      def set_available_locales
        @available_locales = translations.keys.map(&:to_sym)
      end

      def interpolate_if_string(locale, value, options)
        return unless value
        return interpolate(locale, value, options) if value.is_a?(String)

        value
      end
    end
  end
end
