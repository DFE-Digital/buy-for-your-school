# rubocop:disable Rails/SaveBang
class Preview::EntriesController < ApplicationController
  before_action :check_app_is_running_in_preview_env

  def show
    category = Category.create(title: "Preview", contentful_id: 0, liquid_template: "<p>N/A</p>")
    @journey = Journey.create(
      category: category,
      user: current_user,
    )
    section = Section.create(title: "Preview Section", journey: @journey)
    task = Task.create(title: "Preview Task", section: section)

    contentful_entry = GetEntry.new(entry_id: entry_id).call
    @step = CreateStep.new(
      task: task, contentful_entry: contentful_entry, order: 0,
    ).call

    redirect_to journey_step_path(@journey, @step)
  end

private

  def entry_id
    params[:id]
  end

  def check_app_is_running_in_preview_env
    return if ENV["CONTENTFUL_PREVIEW_APP"].eql?("true")

    render "errors/not_found", status: :not_found
  end
end
# rubocop:enable Rails/SaveBang
