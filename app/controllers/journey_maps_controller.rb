# frozen_string_literal: true

class JourneyMapsController < ApplicationController
  rescue_from GetStepsFromSection::RepeatEntryDetected do |exception|
    render "errors/repeat_step_in_the_contentful_journey", status: 500, locals: {error: exception}
  end

  rescue_from GetEntry::EntryNotFound do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  def new
    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    sections = GetSectionsFromCategory.new(category: category).call
    @steps = sections.map { |section|
      GetStepsFromSection.new(section: section).call
    }.flatten
  end
end
