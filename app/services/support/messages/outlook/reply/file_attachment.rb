module Support
  module Messages
    module Outlook
      module Reply
        class FileAttachment
          def self.from_uploaded_file(http_uploaded_file)
            new(file: http_uploaded_file.tempfile, name: http_uploaded_file.original_filename)
          end

          attr_reader :file, :name

          def initialize(file:, name:)
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
