# app/controllers/page_feedbacks_controller.rb
class PageFeedbacksController < ApplicationController
  before_action :set_page_url, only: %i[widget ask_feedback form]

  def widget; end
  def ask_feedback; end

  def form
    # @page_feedback = PageFeedback.new(page_url: @page_url, page_useful: params[:page_useful])
    @page_feedback = PageFeedback.new(page_url: @page_url, page_useful: params[:page_useful], wants_feedback: params[:wants_feedback])
  end

  def create
    # binding.pry
    @page_feedback = PageFeedback.new(page_feedback_params)
    if @page_feedback.save
      render :thanks
    else
      @page_url = @page_feedback.page_url
      render :form, status: :unprocessable_entity
    end
  end

private

  def set_page_url
    # binding.pry
    # @page_useful = params[:page_useful]
    @page_useful = params[:page_useful] == "true"
    @page_url = params[:page_url]
  end

  def page_feedback_params
    params.require(:page_feedback).permit(:page_url, :page_useful, :wants_feedback, :feedback)
  end
end
