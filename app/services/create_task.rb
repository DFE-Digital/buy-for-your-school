class CreateTask
  attr_accessor :section, :contentful_task

  def initialize(section:, contentful_task:)
    @section = section
    @contentful_task = contentful_task
  end

  def call
    task = Task.new(section: section, title: contentful_task.title, contentful_id: contentful_task.id)
    task.save!
    task
  end
end
