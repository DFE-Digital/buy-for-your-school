module HasAttachments
  extend ActiveSupport::Concern

  included do
    attr_reader :attachments
  end

  def initialize(entry)
    @attachments = Array(entry.fields[:attachments]).compact
      .map { |attachment_entry| ContentfulAttachment.new(attachment_entry) }
      .select(&:url)
    super
  end
end
