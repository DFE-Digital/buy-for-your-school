class ActivityLog::Types::ContactUpdatedComponent < ViewComponent::Base
  include ActivityLog::Types::BasicActivityDetails

  delegate :current_url_b64, to: :helpers

  def initialize(activity_log_item:)
    @activity_log_item = activity_log_item
  end

  def contact_name
    contact.try(:name)
  end

  def contact
    contact_id = @activity_log_item.activity.field_changes["contact_id"].last

    Frameworks::ProviderContact.find(contact_id) if contact_id
  end

  def unassigned_contact_name
    unassigned_contact.try(:name)
  end

  def unassigned_contact
    contact_id = @activity_log_item.activity.field_changes["contact_id"].first

    Frameworks::ProviderContact.find(contact_id) if contact_id
  end
end
