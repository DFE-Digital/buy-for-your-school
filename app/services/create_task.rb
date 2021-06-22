# Build and persist a {Task}
class CreateTask
  class UnexpectedContentfulModel < StandardError; end

  attr_accessor :section, :contentful_task, :order

  # @param [Section] section the section this task belongs to
  # @param [Hash<Symbol, String>] contentful_task task attributes provided by Contentful
  # @param [Integer] order task order
  def initialize(section:, contentful_task:, order:)
    @section = section
    @contentful_task = contentful_task
    @order = order
  end

  # This relies on the passed-in `contentful_task` to construct the object.
  #
  # @raise UnexpectedContentfulModel
  # @see CreateJourney#call
  #
  # @return [Task]
  def call
    task = Task.new(
      section: section,
      title: contentful_task.title,
      contentful_id: contentful_task.id,
      order: order,
    )
    begin
      task.save!
      task
    rescue ActiveRecord::RecordInvalid
      raise UnexpectedContentfulModel
    end
  end
end
