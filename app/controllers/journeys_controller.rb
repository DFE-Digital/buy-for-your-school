# frozen_string_literal: true

class JourneysController < ApplicationController
  before_action :check_user_belongs_to_journey?, only: %w[show]

  unless Rails.env.development?
    rescue_from GetCategory::InvalidLiquidSyntax do |exception|
      render "errors/specification_template_invalid", status: 500, locals: {error: exception}
    end

    rescue_from CreateStep::UnexpectedContentfulModel, CreateTask::UnexpectedContentfulModel do |exception|
      render "errors/unexpected_contentful_model", status: 500
    end

    rescue_from CreateStep::UnexpectedContentfulStepType do |exception|
      render "errors/unexpected_contentful_step_type", status: 500
    end

    rescue_from GetEntry::EntryNotFound do |exception|
      render "errors/contentful_entry_not_found", status: 500
    end
  end

  def new
    journey = CreateJourney.new(category_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"], user: current_user).call
    
    RecordAction.new(
      action: "begin_journey",
      journey_id: journey.id,
      user_id: current_user.id,
      contentful_category_id: ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"]
    ).call
    redirect_to journey_path(journey)
  end

  def show
    @journey = current_journey
    @sections = @journey.sections.includes(:tasks).map do |section|
      SectionPresenter.new(section)
    end

    RecordAction.new(
      action: "view_journey",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.contentful_id
    ).call
  end
end
