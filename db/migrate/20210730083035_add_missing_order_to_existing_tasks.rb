class AddMissingOrderToExistingTasks < ActiveRecord::Migration[6.1]
  def up
    return if Task.where(order: nil).none?

    Task.count
    tasks_unordered = Task.where(order: nil)
    tasks_unordered.count

    section_contentful_ids = tasks_unordered.map(&:section).map(&:contentful_id).uniq

    section_contentful_ids.map do |section_id|
      contentful_section = Content::Client.new.by_id(section_id)

      Section.where(contentful_id: section_id).map do |section|
        section.tasks.map do |task|
          contentful_section.tasks.each_with_index do |contentful_task, task_index|
            next unless task.contentful_id == contentful_task.id

            task.update!(order: task_index)
          end
        end
      end
    end
  end

  def down; end
end
