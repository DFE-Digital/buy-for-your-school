module Support
  #
  # Call the MS Graph API to update the attributes of all the timeline documents in SharePoint
  #
  class RefreshTimelineDocumentsJob < ApplicationJob
    queue_as :support

    def perform
      Collaboration::TimelineDocument.all.find_each do |timeline_document|
        drive_item = MicrosoftGraph.files.get_item(timeline_document.ms_graph_drive_item_id)
        next if drive_item.nil?

        timeline_document.update!(
          name: drive_item.name,
          last_modified_by: drive_item.last_modified_by.dig("user", "displayName"),
          last_modified_at: drive_item.last_modified_date_time,
        )
      end
    end
  end
end
