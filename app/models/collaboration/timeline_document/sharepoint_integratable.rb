module Collaboration::TimelineDocument::SharepointIntegratable
  extend ActiveSupport::Concern

  def version_history
    return [] if ms_graph_drive_item_id.nil?

    MicrosoftGraph.files.list_versions(ms_graph_drive_item_id)
  end

  def fetch_url
    return if ms_graph_drive_item_id.nil?

    MicrosoftGraph.files.get_item(ms_graph_drive_item_id).web_url
  end

  def invite_contact_to_collaborate
    MicrosoftGraph.files.add_permissions(ms_graph_drive_item_id, [task.stage.timeline.case.email])
  end

  def create_sharing_url
    return sharing_url if sharing_url.present?

    url = MicrosoftGraph.files.create_sharing_link(ms_graph_drive_item_id)
    update!(url:) if url.present?
  end
end
