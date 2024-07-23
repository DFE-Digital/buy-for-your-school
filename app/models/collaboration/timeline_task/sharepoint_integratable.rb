module Collaboration::TimelineTask::SharepointIntegratable
  extend ActiveSupport::Concern

  def share_documnets_with_contact
    return if documents.empty?

    MicrosoftGraph.files.list_versions(ms_graph_drive_item_id)
  end
end
