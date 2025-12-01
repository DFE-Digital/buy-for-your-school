# frozen_string_literal: true

class Specify::JourneysController < Specify::ApplicationController
  before_action :form, only: %i[create]
  before_action :categories, only: %i[new create]

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
        contentful_category: journey.category.title,
      ).call

      redirect_to journey_path(journey)
    else
      if back_link?
        @form.back!
      elsif validation.success?
        @form.advance!
      end

      render :new
    end
  end

  def edit
    @form = EditJourneyForm.new(**persisted_data)
  end

  # Log 'view_journey'
  #
  # @see SectionPresenter
  def show
    breadcrumb "Dashboard", dashboard_path
    breadcrumb "Create specification", journey_path(current_journey), match: :exact

    @journey = current_journey

    RecordAction.new(
      action: "view_journey",
      journey_id: @journey.id,
      user_id: current_user.id,
      contentful_category_id: @journey.category.contentful_id,
      contentful_category: @journey.category.title,
    ).call
  end

  def update
    @form = EditJourneyForm.new(messages: edit_validation.errors(full: true).to_h, **edit_validation.to_h)
    if edit_validation.success?
      current_journey.update!(**@form.data)
      redirect_to journey_path(current_journey), notice: I18n.t("journey.update.notice")
    else
      render :edit
    end
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
      category name step back
    ])
  end

  def edit_form_params
    params.require(:edit_journey_form).permit(*%i[
      name
    ])
  end

  # @return [NewJourneyFormSchema] validated form input
  def validation
    NewJourneyFormSchema.new.call(**form_params)
  end

  # @return [EditJourneyFormSchema] validated form input
  def edit_validation
    EditJourneyFormSchema.new.call(**edit_form_params)
  end

  # @return [Hash]
  def persisted_data
    current_journey.attributes.symbolize_keys
  end

  # @return [Boolean]
  def back_link?
    @back_link = form_params[:back].eql?("true")
  end

  # @return [Array<CategoryPresenter>]
  def categories
    @categories = Category.published.map { |c| CategoryPresenter.new(c) }
  end
end
