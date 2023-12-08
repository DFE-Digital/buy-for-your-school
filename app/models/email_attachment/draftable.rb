module EmailAttachment::Draftable
  extend ActiveSupport::Concern

  included do
    scope :draft, -> { where(outlook_id: nil) }
  end

  class_methods do
    def delete_draft_attachments_for_email(email)
      email.attachments.draft.destroy_all
    end
  end
end
