# frozen_string_literal: true

class QuestionsController < ApplicationController
  rescue_from GetContentfulEntry::EntryNotFound do |exception|
    render "errors/contentful_entry_not_found", status: 500
  end

  rescue_from CreatePlanningQuestion::UnexpectedContentfulModel do |exception|
    render "errors/unexpected_contentful_model", status: 500
  end

  def new
    @plan = Plan.find(plan_id)

    redirect_to plan_path(@plan) unless @plan.next_entry_id.present?

    contentful_entry = GetContentfulEntry.new(entry_id: @plan.next_entry_id).call
    @question, @answer = CreatePlanningQuestion.new(
      plan: @plan, contentful_entry: contentful_entry
    ).call

    render "new.#{@question.contentful_type}"
  end

  private

  def plan_id
    params[:plan_id]
  end
end
