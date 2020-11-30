# frozen_string_literal: true

class AnswersController < ApplicationController
  def create
    @journey = Journey.find(journey_id)
    @question = Question.find(question_id)

    @answer = AnswerFactory.new(question: @question).call
    @answer.assign_attributes(answer_params)
    @answer.question = @question

    if @answer.valid?
      @answer.save
      if @journey.next_entry_id.present?
        redirect_to new_journey_question_path(@journey)
      else
        redirect_to journey_path(@journey)
      end
    else
      render "questions/new.#{@question.contentful_type}"
    end
  end

  private

  def journey_id
    params[:journey_id]
  end

  def question_id
    params[:question_id]
  end

  def answer_params
    params.require(:answer).permit(:response)
  end
end
