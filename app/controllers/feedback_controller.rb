class FeedbackController < ApplicationController
  def index
    @feedback_form = FeedbackForm.new
  end
end
