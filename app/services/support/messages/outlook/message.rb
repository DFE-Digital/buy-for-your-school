module Support
  module Messages
    module Outlook
      # Intended to decorate MicrosoftGraph::Resource::Message
      class Message < SimpleDelegator
        attr_accessor :mail_folder, :ms_graph_client
        
        def self.from_resource(message, mail_folder:, ms_graph_client:)
          new(message).tap do |decorated|
            decorated.mail_folder = mail_folder
            decorated.ms_graph_client = ms_graph_client
          end
        end

        def attachments
          @attachments ||= ms_graph_client
            .get_file_attachments(SHARED_MAILBOX_USER_ID, id)
            .map {|attachment| MessageAttachment.new(attachment) }
        end

        def detected_existing_case
          @detected_existing_case ||= Synchronisation::MessageCase.new(self).detected_existing_case
        end

        def folder
          mail_folder.folder
        end

        def inbox?
          mail_folder.inbox?
        end

        def sender
          { address: from.email_address.address, name: from.email_address.name }
        end

        def recipients
          to_recipients.map(&:email_address).map do |email_address|
            { address: email_address.address, name: email_address.name }
          end
        end
      end
    end
  end
end
