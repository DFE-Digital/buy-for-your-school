# frozen_string_literal: true

class JourneysController < ApplicationController
  before_action :check_user_belongs_to_journey?, only: %w[show]

  unless Rails.env.development?
    rescue_from GetCategory::InvalidLiquidSyntax do |exception|
      render "errors/specification_template_invalid",
             status: :internal_server_error,
             locals: { error: exception }
    end

    rescue_from CreateStep::UnexpectedContentfulModel,
                CreateTask::UnexpectedContentfulModel do
      render "errors/unexpected_contentful_model",
             status: :internal_server_error
    end

    rescue_from CreateStep::UnexpectedContentfulStepType do
      render "errors/unexpected_contentful_step_type",
             status: :internal_server_error
    end

    rescue_from GetEntry::EntryNotFound do
      render "errors/contentful_entry_not_found",
             status: :internal_server_error
    end
  end

  # Log 'begin_journey'
  #
  # @see CreateJourney
  def create
    category_id = params[:category_id]
    return redirect_to categories_path if category_id.nil?

    category = Category.find(category_id)
    journey = CreateJourney.new(
      category: category,
      user: current_user,
    ).call

    RecordAction.new(
      action: "begin_journey",
      journey_id: journey.id,
      user_id: current_user.id,
      contentful_category_id: category.contentful_id,
    ).call

    redirect_to journey_path(journey)
  end

  # Log 'view_journey'
  #
  # @see SectionPresenter
  def show
    @journey = current_journey
    @sections = @journey.sections.includes(:tasks).map do |section|
      SectionPresenter.new(section)
    end

    RecordAction.new(
      action: "view_journey",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
    ).call
  end
end
