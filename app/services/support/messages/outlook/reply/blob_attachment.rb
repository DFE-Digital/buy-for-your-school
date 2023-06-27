module Support
  module Messages
    module Outlook
      module Reply
        class BlobAttachment < Attachment
          attr_reader :blob

          delegate :content_type, to: :blob

          def initialize(blob)
            super()
            @blob = blob
          end

          def name = @blob.filename.to_s

          def content_bytes
            @blob.open do |temp_file|
              temp_file.rewind
              Base64.encode64(temp_file.read)
            end
          end
        end
      end
    end
  end
end
