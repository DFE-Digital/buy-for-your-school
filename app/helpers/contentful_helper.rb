module ContentfulHelper
module_function

  # Load and flatten translations from a YAML file
  def load_flattened_translations(file_path)
    raise "Error: Translation file not found at #{file_path}" unless File.exist?(file_path)

    translations = YAML.load_file(file_path)
    raise "Error: No translations found in #{file_path}" if translations["en"].nil?

    I18n::Utils.flatten_translations(translations["en"])
  end

  # Publishes an entry in Contentful
  def publish_entry(entry_id, token, space_id)
    client = contentful_management_client(token)
    environment = fetch_environment(client, space_id)

    entry = environment.entries.find(entry_id)
    entry.publish
    Rails.logger.debug "Published entry: #{entry_id}"
  rescue Contentful::Management::Error => e
    Rails.logger.debug "Failed to publish entry #{entry_id}. Error: #{e.message}"
  end

  # Validates required environment variables
  def validate_environment_variables(required_vars)
    missing_vars = required_vars.select { |var| ENV[var].nil? }
    raise "Error: Missing environment variables: #{missing_vars.join(', ')}" if missing_vars.any?
  end

  # Fetches translations from Contentful
  def fetch_contentful_translations(space_id, token)
    client = contentful_management_client(token)
    environment = fetch_environment(client, space_id)
    entries = environment.entries.all(content_type: "translation")

    Rails.logger.debug "Fetched entries (total #{entries.size}):"
    entries.each_with_index do |entry, index|
      Rails.logger.debug "Entry #{index + 1}: #{entry.fields.inspect}"
    end
    entries
  rescue Contentful::Management::Error => e
    raise "Error fetching translations from Contentful: #{e.message}"
  end

  def transform_contentful_translations(entries)
    entries.each_with_object({}) do |entry, hash|
      Rails.logger.debug "Entry Fields: #{entry.fields.inspect}"

      key_field = entry.fields["key"] || entry.fields[:key]
      value_field = entry.fields["value"] || entry.fields[:value]

      Rails.logger.debug "Processing Entry: key_field=#{key_field.inspect}, value_field=#{value_field.inspect}"

      # Normalizes the localized fields (if they are hashes)
      key_field = key_field.is_a?(Hash) ? key_field["en-US"] || key_field[:en_US] : key_field
      value_field = value_field.is_a?(Hash) ? value_field["en-US"] || value_field[:en_US] : value_field

      Rails.logger.debug "Normalized Fields: key_field=#{key_field.inspect}, value_field=#{value_field.inspect}"

      # Skipping if key_field or value_field is missing
      if key_field.nil? || value_field.nil?
        Rails.logger.warn "Skipping entry due to missing key or value: key_field=#{key_field.inspect}, value_field=#{value_field.inspect}"
        next
      end

      hash[key_field] = value_field
    end
  end

  # Creates new translation entries in Contentful
  def create_contentful_entry(key, value, space_id, token)
    client = contentful_management_client(token)
    environment = fetch_environment(client, space_id)
    Rails.logger.debug("Creating new entry for key: #{key}")
    translation_type = environment.content_types.find("translation")
    # rubocop:disable Rails/SaveBang
    new_entry = translation_type.entries.create(
      key: key,
      value: value
    )
    # rubocop:enable Rails/SaveBang
    new_entry.publish
  rescue StandardError => e
    Rails.logger.debug "Failed to create or publish entry for key: #{key}. Error: #{e.message}"
    Rails.logger.error "Failed to create or publish entry for key: #{key}. Error: #{e.message}"
  end

  # Unpublishes an entry in Contentful
  def unpublish_contentful_entry(entry_id, space_id, token)
    client = contentful_management_client(token)
    environment = fetch_environment(client, space_id)

    entry = environment.entries.find(entry_id)
    entry.unpublish
  rescue Contentful::Management::Error => e
    Rails.logger.debug "Failed to unpublish entry #{entry_id}. Error: #{e.message}"
  end

  # Deletes an entry in Contentful
  def delete_contentful_entry(entry_id, space_id, token)
    client = contentful_management_client(token)
    environment = fetch_environment(client, space_id)

    entry = environment.entries.find(entry_id)
    entry.destroy!
  rescue Contentful::Management::Error => e
    Rails.logger.debug "Failed to delete entry #{entry_id}. Error: #{e.message}"
  end

private

  # Initializes the Contentful management client
  def contentful_management_client(token)
    Contentful::Management::Client.new(token)
  end

  # Fetches the environment object from Contentful
  def fetch_environment(client, space_id, environment_id = "master")
    space = client.spaces.find(space_id)
    space.environments.find(environment_id)
  end
end
