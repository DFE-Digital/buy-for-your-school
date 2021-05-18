# frozen_string_literal: true

class JourneysController < ApplicationController
  before_action :check_user_belongs_to_journey?, only: %w[show]

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

  def index
    @journeys = current_user.journeys
  end

  def new
    journey = CreateJourney.new(category_name: "catering", user: current_user).call
    redirect_to journey_path(journey)
  end

  def show
    @journey = current_journey
    @sections = @journey.sections.includes(:tasks)
  end
end
