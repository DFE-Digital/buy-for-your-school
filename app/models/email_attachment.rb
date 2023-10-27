class EmailAttachment < ApplicationRecord
  self.table_name = "support_email_attachments"

  include Cacheable
  include CustomNameable
  include DeDupable
  include Hideable

  has_one_attached :file
  belongs_to :email

  scope :inline, -> { where(is_inline: true) }
  scope :non_inline, -> { where(is_inline: false) }
  scope :for_ticket, ->(ticket_id:) { joins(:email).where(email: { ticket_id: }) }

  delegate :checksum, to: :file
  delegate :ticket, :ticket_id, :ticket_type, to: :email

  def custom_name = super.presence || file_name
end
