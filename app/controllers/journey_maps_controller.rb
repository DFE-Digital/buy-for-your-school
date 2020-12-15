# frozen_string_literal: true

class JourneyMapsController < ApplicationController
  rescue_from BuildJourneyOrder::RepeatEntryDetected do |exception|
    render "errors/repeat_step_in_the_contentful_journey", status: 500, locals: {error: exception}
  end

  def new
    entries = GetAllContentfulEntries.new.call
    @journey_map = BuildJourneyOrder.new(
      entries: entries.to_a,
      starting_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"]
    ).call
  end
end
