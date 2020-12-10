class BuildJourneyOrder
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
    entry = entry_lookup.fetch(next_entry_id, nil)
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
end
