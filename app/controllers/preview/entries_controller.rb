class Preview::EntriesController < ApplicationController
  def show
    client = Content::Client.new(:preview)

    contentful_step = GetEntry.new(entry_id: params[:id], client: client).call

    category = Category.find_or_create_by!(title: "Designer Preview Category") do |c|
      c.contentful_id = 0
      c.description = "Used to demo a step before publishing"
      c.liquid_template = "<p>N/A</p>"
    end

    # flagged for deletion
    journey = Journey.find_or_create_by!(category: category) do |j|
      j.user = current_user
      j.state = 3
    end

    section = Section.find_or_create_by!(title: "Designer Preview Section") do |s|
      s.contentful_id = 0
      s.order = 0
      s.journey = journey
    end

    task = Task.find_or_create_by!(title: "Designer Preview Task") do |t|
      t.contentful_id = 0
      t.order = 0
      t.section = section
      # TODO: add migration for step_tally to default to an empty Hash
      t.step_tally = {}
    end

    step = CreateStep.new(
      task: task,
      contentful_step: contentful_step,
      order: 0,
    ).call

    redirect_to journey_step_path(journey, step)
  end
end
