class CreateTask
  class UnexpectedContentfulModel < StandardError; end

  attr_accessor :section, :contentful_task

  def initialize(section:, contentful_task:)
    @section = section
    @contentful_task = contentful_task
  end

  def call
    task = Task.new(section: section, title: contentful_task.title, contentful_id: contentful_task.id)
    begin
      task.save!
      task
    rescue ActiveRecord::RecordInvalid
      raise UnexpectedContentfulModel
    end
  end
end
