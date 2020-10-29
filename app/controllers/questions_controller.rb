# frozen_string_literal: true

class QuestionsController < ApplicationController
  def new
    @plan = Plan.find(plan_id)
    @question = CreatePlanningQuestion.new(plan: @plan).call
    @answer = Answer.new
    # TODO: Creating a question requires us to check externally if one exists
    # based on the previous question. Instead of looping through at the start,
    # we assume there is and try to create one. If not, we jump to the end.

    redirect_to plan_path(@plan) if @question.nil?
  end

  private

  def plan_id
    params[:plan_id]
  end
end
