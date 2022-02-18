class UserResearchOptInController < ApplicationController
  breadcrumb "Dashboard", :dashboard_path
  breadcrumb "Get involved", :new_feedback_path, match: :exact

  def new
    @feedback_form = UserResearchForm.new
  end

  def create
    @feedback_form = form

    if validation.success?
      feedback = UserFeedback.create!(
        logged_in: !current_user.guest?,
        **@feedback_form.to_h,
      )

      redirect_to feedback_path(feedback)
    else
      render :new
    end
  end

private

  def set_satisfaction_options
    @satisfaction_options = UserFeedback.satisfactions.keys.reverse
  end

  # @return [FeedbackForm] form object populated with validation messages
  def form
    FeedbackForm.new(
      messages: validation.errors(full: true).to_h,
      **validation.to_h,
    )
  end

  def form_params
    params.require(:feedback_form).permit(*%i[
      satisfaction feedback_text
    ])
  end

  # @return [FeedbackFormSchema] validated form input
  def validation
    FeedbackFormSchema.new.call(**form_params)
  end
end
