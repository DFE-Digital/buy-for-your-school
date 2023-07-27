class Specify::FeedbackController < Specify::ApplicationController
  skip_before_action :authenticate_user!

  before_action :form, only: %i[create update]

  breadcrumb "Dashboard", :dashboard_path

  def new
    breadcrumb "Give feedback", :new_feedback_path, match: :exact

    @form = FeedbackForm.new(user: current_user)
  end

  def create
    if validation.success?
      feedback = UserFeedback.create!(**form.data)
      redirect_to feedback_path(feedback)
    else
      render :new
    end
  end

  def edit
    breadcrumb "Get involved", :edit_feedback_path, match: :exact
    @form = FeedbackForm.new(user: current_user, **persisted_data)
  end

  def update
    if validation.success?
      feedback.update!(**form.data)
      redirect_to feedback_path(feedback)
    else
      render :edit
    end
  end

  def show
    @show_view = feedback.full_name ? :details_submitted : :feedback_submitted

    case @show_view
    when :details_submitted
      breadcrumb "Get involved", :edit_feedback_path, match: :exact
    else
      breadcrumb "Give feedback", :new_feedback_path, match: :exact
    end
  end

private

  def feedback
    @feedback = UserFeedback.find_by(id: params[:id])
  end

  # @return [FeedbackForm] form object populated with validation messages
  def form
    @form =
      FeedbackForm.new(
        user: current_user,
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

  # @return [Hash]
  def persisted_data
    feedback.attributes.symbolize_keys
  end
end
