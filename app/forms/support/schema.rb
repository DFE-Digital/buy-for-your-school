module Support
  class Schema < Dry::Validation::Contract
    import_predicates_as_macros

    config.messages.backend = :i18n
    config.messages.top_namespace = :forms
    config.messages.load_paths << Rails.root.join("config/locales/validation/support/en.yml")

    # Create validation rules for given date fields
    #
    # Date fields are expected to be hashes in the format { year: #, month: #, day: # }
    #
    # @param [Array<String>] fields - field names
    def self.validate_date_fields(fields)
      fields.each do |field|
        rule(field) do
          hash_to_date(values[field])
        rescue ArgumentError
          key.failure("is invalid")
        end
      end
    end

  private

    def hash_to_date(field)
      unless field.nil? || field.values.all?(&:blank?)
        Date.new(field["year"].to_i, field["month"].to_i, field["day"].to_i)
      end
    end
  end
end
