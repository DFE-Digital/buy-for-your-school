module Support
  module Messages
    module Outlook
      # Intended to decorate MicrosoftGraph::Resource::Attachment
      class MessageAttachment < SimpleDelegator
        def io
          StringIO.new(content_bytes)
        end

        def filename
          name
        end

        def content_bytes
          Base64.decode64(super)
        end
      end
    end
  end
end
