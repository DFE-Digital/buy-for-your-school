# Fetch and cache Contentful tasks for the section
#
class GetTasksFromSection
  # @return [Contentful::Entry]
  attr_accessor :section

  # @param section [Contentful::Entry]
  def initialize(section:)
    self.section = section
  end

  # @return [Array<Contentful::Entry>]
  def call
    return [] unless section.respond_to?(:tasks)

    task_ids = []
    section.tasks.each do |task|
      task_ids << task.id
    end

    task_ids.map do |entry_id|
      GetEntry.new(entry_id: entry_id).call
    end
  end
end
