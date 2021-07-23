# frozen_string_literal: true

# Renders internal template tags used by Content Designers working with Contentful.
# Used when drafting Liquid template logic in a specification before publishing.
#
# @example
#   {{ answer_<%= entry.id %> }}
#
class DesignController < ApplicationController
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

  def index
    @categories = ContentfulConnector.new.by_type("category")
  end

  # TODO: introduce service function JourneyMapper#call that receives a category_id and returns steps
  def show
    contentful_category = ContentfulConnector.new.by_slug("category", params[:id])
    sections = GetSectionsFromCategory.new(category: contentful_category).call
    tasks = sections.flat_map { |section| GetTasksFromSection.new(section: section).call }
    # TODO: wrap steps in presenter and relocate the link_to Contentful url there
    @steps = tasks.flat_map { |task| GetStepsFromTask.new(task: task).call }

    flash[:notice] = "#{contentful_category.environment.id.capitalize} Environment"
  end
end
