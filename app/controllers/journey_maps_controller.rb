# frozen_string_literal: true

class JourneyMapsController < ApplicationController
  def new
    hash_of_entries = GetAllContentfulEntries.new.call.to_h { |entry| [entry.id, entry] }
    @journey_map = recursive_path(
      all_entries: hash_of_entries,
      next_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"],
      entry_id_sequence: []
    )
  end

  def recursive_path(all_entries:, next_entry_id:, entry_id_sequence:)
    entry = all_entries.fetch(next_entry_id, nil)
    entry_id_sequence << entry.id if entry.present?

    if entry.respond_to?(:next)
      recursive_path(
        all_entries: all_entries,
        next_entry_id: entry.next.id,
        entry_id_sequence: entry_id_sequence
      )
    else
      entry_id_sequence
    end
  end
end
