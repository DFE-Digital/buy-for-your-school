# frozen_string_literal: true

class JourneysController < ApplicationController
  before_action :check_user_belongs_to_journey?, only: %w[show destroy]
  before_action :get_journey, only: %w[show destroy]

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
    return redirect_to categories_path unless params[:category_id]

    category = Category.find(params[:category_id])
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

  # Mark journey as remove
  #
  # @see Journey#state
  def destroy
    if params[:confirm] == "true"
      render :confirm_delete
    else
      @journey.remove!
      render :delete
    end
  end

private

  def get_journey
    @journey = current_journey
  end

  def get_category(category_id = ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"])
    Category.find_or_create_by!(contentful_id: category_id) do |category|
      contentful_category = GetCategory.new(category_entry_id: category.contentful_id).call
      category.title = contentful_category.title
      category.description = contentful_category.description
      category.liquid_template = contentful_category.combined_specification_template
    end
  end
end
