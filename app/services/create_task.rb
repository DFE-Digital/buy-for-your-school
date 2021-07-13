# Convert a {Contentful::Entry} into a {Task}
#
class CreateTask
  class UnexpectedContentfulModel < StandardError; end

  attr_accessor :section, :contentful_task, :order

  # @param section [Section] persisted section
  # @param contentful_task [Contentful::Entry] Contentful Client object
  # @param order [Integer] position within the section
  #
  def initialize(section:, contentful_task:, order:)
    @section = section
    @contentful_task = contentful_task
    @order = order
  end

  # This relies on the passed-in `contentful_task` to construct the object.
  # @see CreateJourney#call
  #
  # @raise [UnexpectedContentfulModel]
  # @return [Task]
  #
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
    # TODO: why might the record be invalid? we are missing coverage here
    rescue ActiveRecord::RecordInvalid
      raise UnexpectedContentfulModel
    end
  end
end
