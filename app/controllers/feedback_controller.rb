class FeedbackController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :set_satisfaction_options, only: %i[new create]
  before_action :show_view, only: %i[show]
  before_action :form, only: %i[create update]

  helper_method :form, :show_view

  breadcrumb "Dashboard", :dashboard_path
  breadcrumb "Get involved", :new_feedback_path, match: :exact

  def new
    @form = FeedbackForm.new
  end

  def create
    if validation.success?
      redirect_to feedback_path(
        UserFeedback.create!(
          logged_in: !current_user.guest?,
          logged_in_as: current_user&.id,
          **form.to_h,
        )
      )
    else
      render :new
    end
  end

  def edit
    @form = FeedbackForm.new(**feedback.to_h.compact)
  end

  def update
    if validation.success?
      feedback.update!(**form.to_h.compact)
      redirect_to feedback_path(feedback)
    else
      render :edit
    end
  end

  def show; end

private

  def set_satisfaction_options
    @satisfaction_options = UserFeedback.satisfactions.keys.reverse
  end

  def feedback
    @feedback ||= UserFeedback.find_by(id: params[:id])
  end

  # @return [FeedbackForm] form object populated with validation messages
  def form
    @form ||= FeedbackForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def form_params
    params.require(:feedback_form).permit(*%i[
      satisfaction feedback_text full_name email
    ])
  end

  # @return [FeedbackFormSchema] validated form input
  def validation
    FeedbackFormSchema.new.call(**form_params)
  end

  def show_view
    @show_view ||= if feedback.full_name.present?
      :details_submitted
    else
      :feedback_submitted
    end
  end
end
