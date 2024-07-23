class Collaboration::TimelineTask::FilePicker
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor(
    :timeline_task,
    :document_source,
  )

  attr_reader(
    :documents,
  )

  def initialize(attributes = {})
    super
    @documents = @timeline_task.documents.map(&:ms_graph_drive_item_id)
  end

  def pick_documents(document_ids)
    @documents = @document_source.filter { |doc| document_ids.include?(doc.id) }
  end

  def save!
    @timeline_task.transaction do
      document_ids = @documents.map(&:id)
      @timeline_task.documents.filter { |timeline_doc| document_ids.exclude?(timeline_doc.ms_graph_drive_item_id) }.each(&:destroy!)
      @documents.each do |doc|
        @timeline_task.documents.find_or_create_by(ms_graph_drive_item_id: doc.id) do |timeline_doc|
          timeline_doc.name = doc.name
          timeline_doc.last_modified_at = doc.last_modified_date_time
          timeline_doc.last_modified_by = doc.last_modified_by.dig("user", "displayName")
        end
      end
    end
  end
end
