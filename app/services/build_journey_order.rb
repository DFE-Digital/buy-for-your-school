class BuildJourneyOrder
  class RepeatEntryDetected < StandardError; end

  class TooManyChainedEntriesDetected < StandardError; end

  class MissingEntryDetected < StandardError; end

  ENTRY_JOURNEY_MAX_LENGTH = 50

  attr_accessor :entries, :starting_entry_id

  def initialize(entries:, starting_entry_id:)
    self.entries = entries
    self.starting_entry_id = starting_entry_id
  end

  def call
    recursive_path(
      entry_lookup: entry_lookup_hash,
      next_entry_id: starting_entry_id,
      entries: []
    )
  end

  private

  def entry_lookup_hash
    @entry_lookup_hash ||= entries.to_h { |entry| [entry.id, entry] }
  end

  def recursive_path(entry_lookup:, next_entry_id:, entries:)
    begin
      entry = entry_lookup.fetch(next_entry_id)
    rescue KeyError
      send_rollbar_error(message: "A specified Contentful entry was not found", entry_id: next_entry_id)
      raise MissingEntryDetected.new(next_entry_id)
    end

    if entries.include?(entry)
      send_rollbar_error(message: "A repeated Contentful entry was found in the same journey", entry_id: entry.id)
      raise RepeatEntryDetected.new(entry.id)
    end

    if entries.count >= ENTRY_JOURNEY_MAX_LENGTH
      send_rollbar_error(message: "More than #{ENTRY_JOURNEY_MAX_LENGTH} steps were found in a journey map", entry_id: entry.id)
      raise TooManyChainedEntriesDetected.new(entry.id)
    end

    entries << entry if entry.present?

    if entry.respond_to?(:next)
      recursive_path(
        entry_lookup: entry_lookup,
        next_entry_id: entry.next.id,
        entries: entries
      )
    else
      entries
    end
  end

  def send_rollbar_error(message:, entry_id:)
    Rollbar.error(
      message,
      contentful_url: ENV["CONTENTFUL_URL"],
      contentful_space_id: ENV["CONTENTFUL_SPACE"],
      contentful_environment: ENV["CONTENTFUL_ENVIRONMENT"],
      contentful_entry_id: entry_id
    )
  end
end
