# frozen_string_literal: true

class JourneyMapsController < ApplicationController
  def new
    entries = GetAllContentfulEntries.new.call
    @journey_map = BuildJourneyOrder.new(
      entries: entries.to_a,
      starting_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"]
    ).call
  end
end
