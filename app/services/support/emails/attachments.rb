module Support
  module Emails
    class Attachments
      TYPES = {
        "template_attachment" => Support::EmailTemplateAttachment,
      }.freeze

      def self.resolve_blob_attachments(blob_attachments)
        blob_attachments.map do |attachment|
          klass = get_class(attachment["type"])
          klass.find(attachment["file_id"])
        end
      end

      def self.get_class(type) = TYPES[type]

      def self.get_type(klass) = TYPES.key(klass)
    end
  end
end
