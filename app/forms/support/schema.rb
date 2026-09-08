module Support
  class Schema < Dry::Validation::Contract
    import_predicates_as_macros

    config.messages.backend = :i18n
    config.messages.top_namespace = :forms
    config.messages.load_paths << Rails.root.join("config/locales/validation/support/en.yml")

  private

    # @return [DateBuilder]
    def hash_to_date
      @hash_to_date ||= DateBuilder.new
    end

    def validate_date_parts(rule, field, value, min:, max:)
      parts = value.transform_keys(&:to_s)

      day   = parts["day"]
      month = parts["month"]
      year  = parts["year"]

      if [day, month, year].all?(&:blank?)
        rule.key(field).failure(:missing)
        return
      end

      if [day, month, year].any?(&:blank?)
        rule.key(:"#{field}_day").failure(:missing_day) if day.blank?
        rule.key(:"#{field}_month").failure(:missing_month) if month.blank?
        rule.key(:"#{field}_year").failure(:missing_year) if year.blank?
        return
      end

      date = hash_to_date.call(parts)

      unless date
        rule.key(field).failure(:invalid_date)
        return
      end

      rule.key(field).failure(:invalid_range) unless date.between?(min, max)
    end
  end
end
