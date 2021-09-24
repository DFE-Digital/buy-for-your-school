class Preview::EntriesController < ApplicationController
  def show
    contentful_step = GetEntry.new(entry_id: params[:id], client: client).call

    category = Category.find_or_create_by!(
      title: "Designer Preview Category",
      contentful_id: 0,
      description: "Used to demo a step before publishing",
      liquid_template: "<p>N/A</p>",
      slug: "preview",
    )

    journey = Journey.find_or_create_by!(
      category: category,
      user: current_user.__getobj__,
      state: 3, # flagged for deletion
    )

    section = Section.find_or_create_by!(
      title: "Designer Preview Section",
      contentful_id: 0,
      order: 0,
      journey: journey,
    )

    task = Task.find_or_create_by!(
      title: "Designer Preview Task",
      contentful_id: 0,
      order: 0,
      section: section,
    )

    step = CreateStep.new(
      task: task,
      contentful_step: contentful_step,
      order: 0,
    ).call

    redirect_to journey_step_path(journey, step, preview: true)
  end

private

  def client
    Content::Client.new(:preview)
  end
end
