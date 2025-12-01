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
    @back_url = root_path

    flash[:notice] = env_banner

    @categories = client.by_type(:category).map { |e| ContentfulEntryPresenter.new(e) }
  end

  # TODO: introduce service function JourneyMapper#call that receives a category_id and returns steps
  def show
    flash[:notice] = env_banner

    @category = ContentfulEntryPresenter.new(client.by_slug(:category, params[:id]))

    contentful_sections = GetSectionsFromCategory.new(category: @category).call

    contentful_tasks = contentful_sections.flat_map do |contentful_section|
      GetTasksFromSection.new(section: contentful_section).call
    end

    @steps = contentful_tasks.flat_map do |contentful_task|
      steps = GetStepsFromTask.new(task: contentful_task).call
      steps.map { |s| ContentfulEntryPresenter.new(s) }
    end
  end

private

  def client
    Content::Client.new
  end

  def env_banner
    I18n.t("banner.design", env: client.environment.capitalize)
  end
end
