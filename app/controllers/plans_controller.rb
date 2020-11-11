# frozen_string_literal: true

class PlansController < ApplicationController
  def new
    plan = Plan.create(category: "catering", next_entry_id: ENV["CONTENTFUL_PLANNING_START_ENTRY_ID"])
    redirect_to new_plan_question_path(plan)
  end

  def show
    @plan = Plan.includes(questions: [:answer, :radio_answer]).find(plan_id)
  end

  private

  def plan_id
    params[:id]
  end
end
