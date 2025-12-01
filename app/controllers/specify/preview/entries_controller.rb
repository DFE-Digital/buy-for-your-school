class Specify::Preview::EntriesController < Specify::ApplicationController
  def show
    contentful_step = GetEntry.new(entry_id: params[:id], client:).call

    category = Category.find_or_create_by!(
      title: "Designer Preview Category",
      contentful_id: 0,
      description: "Used to demo a step before publishing",
      liquid_template: "<p>N/A</p>",
      slug: "preview",
    )

    journey = Journey.find_or_create_by!(
      category:,
      user: current_user,
      state: 3, # flagged for deletion
    )

    section = Section.find_or_create_by!(
      title: "Designer Preview Section",
      contentful_id: 0,
      order: 0,
      journey:,
    )

    task = Task.find_or_create_by!(
      title: "Designer Preview Task",
      contentful_id: 0,
      order: 0,
      section:,
    )

    step = CreateStep.new(
      task:,
      contentful_step:,
      order: 0,
    ).call

    redirect_to journey_step_path(journey, step, preview: true)
  end

private

  def client
    Content::Client.new(:preview)
  end
end
