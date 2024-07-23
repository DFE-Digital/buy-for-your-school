module Support::Case::SharepointIntegratable
  extend ActiveSupport::Concern

  def initialise_default_documents!
    return if sharepoint_folder_id.present?

    status_report_url = MicrosoftGraph.files.copy(ref)
    Support::PollCopiedItemJob.perform_now(status_report_url, id) if status_report_url.present?
  end

  def fetch_documents_for_stage(stage)
    return [] if sharepoint_folder_id.blank?

    root_folders = MicrosoftGraph.files.list_child_items(sharepoint_folder_id)
    stage_folder = root_folders.find { |folder| folder.name.include?("Stage #{stage}") }
    MicrosoftGraph.files.list_child_items(stage_folder.id)
  end

  def invite_contact_to_sharepoint
    MicrosoftGraph.files.create_guest_invitation("#{first_name} #{last_name}", email)
  end
end
