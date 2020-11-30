class Preview::EntriesController < ApplicationController
  def show
    @journey = Journey.create(category: "catering", next_entry_id: entry_id)
    redirect_to new_journey_step_path(@journey)
  end

  private

  def entry_id
    params[:id]
  end
end
