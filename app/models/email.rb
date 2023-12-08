class Email < ApplicationRecord
  self.table_name = "support_emails"

  include Actionable
  include MessageCacheable
  include Presentable
  include Queryable

  belongs_to :ticket, polymorphic: true, optional: true
  belongs_to :thread, class_name: "MessageThread", primary_key: :conversation_id, foreign_key: :outlook_conversation_id, optional: true
  belongs_to :template, class_name: "Support::EmailTemplate", optional: true
  has_one    :in_reply_to, class_name: "Email", foreign_key: :outlook_internet_message_id, primary_key: :in_reply_to_id
  has_many   :replies, class_name: "Email", foreign_key: :in_reply_to_id, primary_key: :outlook_internet_message_id
  has_many   :attachments, class_name: "EmailAttachment"

  enum folder: { inbox: 0, sent_items: 1 }

  scope :display_order, -> { order("sent_at DESC") }

  def blob_attachment_picker(params = {})
    Email::BlobAttachmentPicker.new(email: self, **params)
  end

  def file_attachment_uploader(params = {})
    Email::FileAttachmentUploader.new(email: self, **params)
  end
end
