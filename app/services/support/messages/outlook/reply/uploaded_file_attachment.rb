module Support
  module Messages
    module Outlook
      module Reply
        class UploadedFileAttachment < Attachment
          attr_reader :file, :name

          def initialize(file:, name:)
            super()
            @file = file
            @name = name
          end

          def content_bytes
            file.rewind
            Base64.encode64(file.read)
          end

          def content_type
            Rack::Mime.mime_type(File.extname(file))
          end
        end
      end
    end
  end
end
