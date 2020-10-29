# frozen_string_literal: true

class AnswersController < ApplicationController
  def create
    plan = Plan.find(plan_id)
    question = Question.find(question_id)

    answer = Answer.new(answer_params)
    answer.question = question
    answer.save

    redirect_to plan_path(plan)
  end

  private

  def plan_id
    params[:plan_id]
  end

  def question_id
    params[:question_id]
  end

  def answer_params
    params.require(:answer).permit(:response)
  end
end
