module Frameworks::Evaluation::EmailTicketable
  extend ActiveSupport::Concern

  included do
    has_many :emails, as: :ticket, after_add: :on_email_attached

    has_many :email_attachments, class_name: "EmailAttachment", through: :emails, source: :attachments

    has_many :message_threads, class_name: "MessageThread", as: :ticket
  end

  def email_prefix
    "[#{reference}]"
  end

  def unique_attachments(folder: "all")
    UniqueAttachments.new(ticket: self, folder:)
  end

  class_methods do
    def on_email_cached(email)
      return if email.ticket.present?

      evaluation = find_by_email(email)
      evaluation.emails << email if evaluation.present?
    end

    def find_by_email(email)
      _, reference = *email.subject.match(/\[(FE[0-9]+)\]/)

      find_by(reference:) if reference.present?
    end
  end

private

  def on_email_attached(email)
    update!(action_required: true) if email.inbox?
  end
end
