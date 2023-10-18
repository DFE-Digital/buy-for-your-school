module Support
  class EmailAttachment < ::EmailAttachment
    include DeDupable
    include Hideable

    scope :for_case, ->(case_id:) { joins(:email).where(email: { ticket_id: case_id }) }

    delegate :case, :case_id, :ticket_id, to: :email
  end
end
