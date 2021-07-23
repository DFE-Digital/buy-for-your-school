# rubocop:disable Rails/SaveBang
class Preview::EntriesController < ApplicationController
  def show
    category = Category.create(title: "Preview", contentful_id: 0, liquid_template: "<p>N/A</p>")
    @journey = Journey.create(category: category, user: current_user)
    section = Section.create(title: "Preview Section", journey: @journey)
    task = Task.create(title: "Preview Task", section: section)
    contentful_entry = GetEntry.new(entry_id: params[:id]).call
    @step = CreateStep.new(task: task, contentful_step: contentful_entry, order: 0).call

    redirect_to journey_step_path(@journey, @step)
  end
end
# rubocop:enable Rails/SaveBang
