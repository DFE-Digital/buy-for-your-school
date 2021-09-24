# frozen_string_literal: true

class JourneysController < ApplicationController
  breadcrumb "Dashboard", :dashboard_path

  before_action :check_user_belongs_to_journey?, only: %w[show destroy]
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
    return redirect_to categories_path unless params[:category]

    category = Category.find_by(slug: params[:category])
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
    breadcrumb "Create specification", journey_path(current_journey), match: :exact

    @journey = JourneyPresenter.new(current_journey)

    RecordAction.new(
      action: "view_journey",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
    ).call
  end

  # Mark journey as remove
  #
  # @see Journey#state
  def destroy
    @journey = JourneyPresenter.new(current_journey)

    if params[:confirm] == "true"
      render :confirm_delete
    else
      current_journey.remove!
      render :delete
    end
  end
end
