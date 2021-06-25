class GetTasksFromSection
  attr_accessor :section

  def initialize(section:)
    self.section = section
  end

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
