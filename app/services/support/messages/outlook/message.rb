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
            .map { |attachment| ::Support::Messages::Outlook::MessageAttachment.new(attachment) }
        end

        delegate :folder, to: :mail_folder

        delegate :inbox?, to: :mail_folder

        def sender
          { address: from.email_address.address, name: from.email_address.name }
        end

        def recipients = to_recipients + cc_recipients + bcc_recipients

        def to_recipients = map_recipients(super)

        def cc_recipients = map_recipients(super)

        def bcc_recipients = map_recipients(super)

      private

        def map_recipients(recipients_to_map)
          recipients_to_map.map(&:email_address).map do |email_address|
            { address: email_address.address, name: email_address.name }
          end
        end
      end
    end
  end
end
