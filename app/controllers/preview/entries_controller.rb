class Preview::EntriesController < ApplicationController
  def show
    @journey = Journey.create(
      category: "catering",
      user: current_user,
      liquid_template: "<p>N/A</p>"
    )

    contentful_entry = GetEntry.new(entry_id: entry_id).call
    @step = CreateJourneyStep.new(
      journey: @journey, contentful_entry: contentful_entry
    ).call

    redirect_to journey_step_path(@journey, @step)
  end

  private

  def entry_id
    params[:id]
  end
end
