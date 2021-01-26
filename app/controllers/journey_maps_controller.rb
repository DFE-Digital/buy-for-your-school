# frozen_string_literal: true

class JourneyMapsController < ApplicationController
  rescue_from GetEntriesInCategory::RepeatEntryDetected do |exception|
    render "errors/repeat_step_in_the_contentful_journey", status: 500, locals: {error: exception}
  end

  rescue_from GetContentfulEntry::EntryNotFound do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  def new
    @journey_map = GetEntriesInCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
  end
end
