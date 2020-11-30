# frozen_string_literal: true

class QuestionsController < ApplicationController
  rescue_from GetContentfulEntry::EntryNotFound do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  rescue_from CreateJourneyQuestion::UnexpectedContentfulModel do |exception|
    render "errors/unexpected_contentful_model", status: 500
  end

  rescue_from CreateJourneyQuestion::UnexpectedContentfulQuestionType do |exception|
    render "errors/unexpected_contentful_question_type", status: 500
  end

  def new
    @journey = Journey.find(journey_id)

    redirect_to journey_path(@journey) unless @journey.next_entry_id.present?

    contentful_entry = GetContentfulEntry.new(entry_id: @journey.next_entry_id).call
    @question, @answer = CreateJourneyQuestion.new(
      journey: @journey, contentful_entry: contentful_entry
    ).call

    render "new.#{@question.contentful_type}"
  end

  private

  def journey_id
    params[:journey_id]
  end
end
