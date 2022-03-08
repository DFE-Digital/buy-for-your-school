# frozen_string_literal: true

class JourneysController < ApplicationController
  before_action :form, only: %i[create]
  before_action :categories, only: %i[new create]

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

  def new
    @form = NewJourneyForm.new(user: current_user)
  end

  # Log 'begin_journey'
  #
  # @see CreateJourney
  def create
    if validation.success? && validation.to_h[:name]
      journey = CreateJourney.new(**form.data).call

      RecordAction.new(
        action: "begin_journey",
        journey_id: journey.id,
        user_id: journey.user.id,
        contentful_category_id: journey.category.contentful_id,
      ).call

      redirect_to journey_path(journey)
    else
      if validation.success?
        @form.advance!
      end

      render :new
    end
  end

  # Log 'view_journey'
  #
  # @see SectionPresenter
  def show
    breadcrumb "Create specification", journey_path(current_journey), match: :exact

    @journey = current_journey

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
      @current_journey.remove!
      render :delete
    end
  end

private

  # @return [NewJourneyForm] form object populated with validation messages
  def form
    @form =
      NewJourneyForm.new(
        user: current_user,
        messages: validation.errors(full: true).to_h,
        **validation.to_h,
      )
  end

  def form_params
    params.require(:new_journey_form).permit(*%i[
      category name step
    ])
  end

  # @return [NewJourneyFormSchema] validated form input
  def validation
    NewJourneyFormSchema.new.call(**form_params)
  end

  # @return [Array<CategoryPresenter>]
  def categories
    populate_categories if Category.none?
    @categories = Category.published.map { |c| CategoryPresenter.new(c) }
  end

  # CMS: initialise Content::Client in the base controller
  def client
    Content::Client.new
  end

  # On an initial run the `categories` table will be empty
  #
  def populate_categories
    client.by_type(:category).each do |entry|
      contentful_category = GetCategory.new(category_entry_id: entry.id).call

      # TODO: create category service
      Category.find_or_create_by!(contentful_id: contentful_category.id) do |category|
        category.title = contentful_category.title
        category.description = contentful_category.description
        category.liquid_template = contentful_category.combined_specification_template
        category.slug = contentful_category.slug
      end
    end
  end
end
