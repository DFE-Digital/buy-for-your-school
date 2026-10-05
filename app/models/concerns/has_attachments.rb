module HasAttachments
  extend ActiveSupport::Concern

  included do
    attr_reader :attachments
  end

  def initialize(entry)
    @attachments = Array(entry.fields[:attachments]).compact.map { |asset| ContentfulAttachment.new(asset) }
  end
end
