# frozen_string_literal: true

require "dry-initializer"

require "types"

# @abstract Use Gov.uk Notify to communicate via email
#
# @see https://docs.notifications.service.gov.uk/ruby.html
# @see https://github.com/alphagov/notifications-ruby-client
#
# @author Peter Hamilton
#
# @example Send an email
#   Notify::Email.new(recipient: User.first).call
#
# @private
module Notify
  class Email
    extend Dry::Initializer

    # @param recipient [Mixed] Person with name(s) and email address
    option :recipient

    # @param client [Notifications::Client] API interface
    option :client, default: proc { Notifications::Client.new(ENV["NOTIFY_API_KEY"]) }

    # @see https://www.notifications.service.gov.uk/services/<UUID>/templates
    #
    # @param template [String] Template by name
    option :template, Types::String, default: proc { "Default" }

    # @param variables [Hash] Additional template variables
    option :variables, Types::Hash, default: proc { {} }

    # This reference identifies a single unique notification or a batch of notifications.
    # It must not contain any personal information such as name or postal address.
    #
    # @param reference [String] A unique identifier you can create if necessary
    option :reference, Types::String, default: proc { "generic" }

    # @param attachment [String] Attachment by path to file
    option :attachment, Types::String, optional: true

    # Send message and rescue from errors
    #
    #   - [ArgumentError] attachment file size exceeding 2MB
    #   - [Notifications::Client::AuthError] API auth failure
    #   - [Notifications::Client::BadRequestError] missing variable or service permission
    #
    # @return [Notifications::Client::ResponseNotification, String] email or error message
    #
    def call
      send_message
    rescue ::ArgumentError,
           ::Notifications::Client::AuthError,
           ::Notifications::Client::BadRequestError => e
      e.message
    end

  private

    # @return [Notifications::Client::ResponseNotification]
    #
    def send_message
      client.send_email(
        # `email_reply_to_id` can be omitted if the service only has one email
        # reply-to address, or you want to use the default email address.
        #
        # email_reply_to_id: "",
        email_address: recipient.email,
        template_id: template_id,
        reference: reference,
        personalisation: personalisation,
      )
    end

    # Adds `link_to_file` template variable
    #
    # @return [Hash]
    #
    def personalisation
      if attachment
        template_params.merge(link_to_file: link_to_file)
      else
        template_params
      end
    end

    # @example
    #     "Hello ((first_name)) ((last name))"
    #
    # snake_case underscores can be omitted
    #
    # @return [Hash<Symbol>] Keys are substituted in the template
    def template_params
      {
        reference: reference,
        first_name: recipient.first_name,
        last_name: recipient.last_name,
        email: recipient.email,
        **variables,
      }
    end

    # Read binary data
    # NB: files larger than 2MB will raise an error.
    #
    # @see https://docs.notifications.service.gov.uk/ruby.html#send-a-file-by-email
    #
    # @return [Hash]
    #
    def link_to_file
      csv = File.extname(attachment).eql?(".csv")

      File.open(attachment, "rb") do |file|
        Notifications.prepare_upload(file, csv)
      end
    end

    # @return [Array<Notifications::Client::Template>] Available email templates
    #
    def templates
      client.get_all_templates(type: "email").collection
    end

    # @return [String] UUID of chosen template
    #
    def template_id
      templates.detect { |t| t.name.eql?(template) }.id
    end
  end
end
