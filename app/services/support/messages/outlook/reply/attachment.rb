module Support
  module Messages
    module Outlook
      module Reply
        class Attachment
          def self.create(attachment)
            case attachment
            when ActionDispatch::Http::UploadedFile
              UploadedFileAttachment.new(file: attachment.tempfile, name: attachment.original_filename)
            when ActiveStorage::Blob
              BlobAttachment.new(attachment)
            end
          end
        end
      end
    end
  end
end
