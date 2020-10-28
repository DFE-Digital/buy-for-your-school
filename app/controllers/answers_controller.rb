# frozen_string_literal: true

class AnswersController < ApplicationController
  def create
    plan = Plan.find(plan_id)
    question = Question.find(question_id)

    Answer.create(response: params[:response], question: question)
    redirect_to plan_path(plan)
  end

  private

  def plan_id
    params[:plan_id]
  end

  def question_id
    params[:question_id]
  end
end
