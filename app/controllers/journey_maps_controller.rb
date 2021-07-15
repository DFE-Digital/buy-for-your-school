# frozen_string_literal: true

# Renders internal template tags used by Content Designers working with Contentful.
# Used when drafting Liquid template logic in a specification before publishing.
#
# @example
#   {{ answer_<%= entry.id %> }}
#
class JourneyMapsController < ApplicationController
  unless Rails.env.development?
    rescue_from GetStepsFromTask::RepeatEntryDetected do |exception|
      render "errors/repeat_step_in_the_contentful_journey",
             status: :internal_server_error,
             locals: { error: exception }
    end

    rescue_from GetEntry::EntryNotFound do
      render "errors/contentful_entry_not_found",
             status: :internal_server_error
    end
  end

  # TODO: introduce service function JourneyMapper#call that receives a category_id and returns steps
  def new
    category = GetCategory.new(category_entry_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]).call
    sections = GetSectionsFromCategory.new(category: category).call
    tasks = sections.flat_map { |section| GetTasksFromSection.new(section: section).call }
    # TODO: wrap steps in presenter and relocate the link_to Contentful url there
    @steps = tasks.flat_map { |task| GetStepsFromTask.new(task: task).call }

    flash[:notice] = "#{contentful_category.environment.id.capitalize} Environment"
  end

  def index
    @categories = ContentfulConnector.new.get_entries_by_type("category")
  end
end
