class CreateTask
  class UnexpectedContentfulModel < StandardError; end

  attr_accessor :section, :contentful_task, :order

  def initialize(section:, contentful_task:, order:)
    @section = section
    @contentful_task = contentful_task
    @order = order
  end

  def call
    task = Task.new(
      section: section,
      title: contentful_task.title,
      contentful_id: contentful_task.id,
      order: order
      )
    begin
      task.save!
      task
    rescue ActiveRecord::RecordInvalid
      raise UnexpectedContentfulModel
    end
  end
end
