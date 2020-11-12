class Preview::EntriesController < ApplicationController
  def show
    @plan = Plan.create(category: "catering", next_entry_id: entry_id)
    redirect_to new_plan_question_path(@plan)
  end

  private

  def entry_id
    params[:id]
  end
end
