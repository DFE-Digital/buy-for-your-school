# Fetch and cache Contentful tasks for the section
#
class GetTasksFromSection
  # @param section [Contentful::Entry]
  # @param client [Content::Client]
  #
  def initialize(section:, client: Content::Client.new)
    @section = section
    @client = client
  end

  # @return [Array<Contentful::Entry>]
  def call
    return [] unless @section.respond_to?(:tasks)

    task_ids = []
    @section.tasks.each do |task|
      task_ids << task.id
    end

    task_ids.map do |entry_id|
      GetEntry.new(entry_id: entry_id, client: @client).call
    end
  end
end
