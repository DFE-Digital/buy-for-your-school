# # Always load the gem so Zeitwerk sees the MicrosoftGraph::* constants
# require "microsoft_graph"

# # let the app boot even if MS Graph is not configured
# ENABLE_MS_GRAPH = ActiveModel::Type::Boolean.new.cast(ENV["ENABLE_MS_GRAPH"])

# if ENABLE_MS_GRAPH &&
#     ENV["MS_GRAPH_CLIENT_ID"].present? &&
#     ENV["MS_GRAPH_CLIENT_SECRET"].present? &&
#     ENV["MS_GRAPH_TENANT"].present?

#   configuration = MicrosoftGraph::ClientConfiguration.new(
#     tenant: ENV.fetch("MS_GRAPH_TENANT"),
#     client_id: ENV.fetch("MS_GRAPH_CLIENT_ID"),
#     client_secret: ENV.fetch("MS_GRAPH_CLIENT_SECRET"),
#     scope: "https://graph.microsoft.com/.default".freeze,
#     grant_type: "client_credentials".freeze,
#   )

#   authenticator = MicrosoftGraph::ApplicationAuthenticator.new(configuration)
#   client_session = MicrosoftGraph::ClientSession.new(authenticator:)

#   MicrosoftGraph.client = MicrosoftGraph::Client.new(client_session)

#   SHARED_MAILBOX_USER_ID = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_USER_ID")
#   SHARED_MAILBOX_NAME = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_NAME")
#   SHARED_MAILBOX_ADDRESS = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_ADDRESS")

#   Rails.configuration.to_prepare do
#     Email.set_default_mailbox(
#       user_id: ENV.fetch("MS_GRAPH_SHARED_MAILBOX_USER_ID"),
#       name: ENV.fetch("MS_GRAPH_SHARED_MAILBOX_NAME"),
#       email_address: ENV.fetch("MS_GRAPH_SHARED_MAILBOX_ADDRESS"),
#     )

#     Email.on_new_message_cached_handlers.add ->(email) { EmailAttachment.delete_draft_attachments_for_email(email) }
#     Email.on_new_message_cached_handlers.add ->(email) { EmailAttachment.cache_attachments_for_email(email) }
#     Email.on_new_message_cached_handlers.add ->(email) { Frameworks::Evaluation.on_email_cached(email) }
#     Email.on_new_message_cached_handlers.add ->(email) { Support::Case.on_email_cached(email) }
#   end

# else
#   Rails.logger.info("[MSGraph] client not configured – gem loaded, but credentials/flag missing")
# end

# Always load the gem so Zeitwerk sees MicrosoftGraph::* constants
# require "microsoft_graph"

# ENABLE_MS_GRAPH = ActiveModel::Type::Boolean.new.cast(ENV["ENABLE_MS_GRAPH"])

# # Provide constants whether or not we have real creds
# SHARED_MAILBOX_USER_ID = ENV["MS_GRAPH_SHARED_MAILBOX_USER_ID"] || "dummy-user-id"
# SHARED_MAILBOX_NAME    = ENV["MS_GRAPH_SHARED_MAILBOX_NAME"]    || "dummy-mailbox"
# SHARED_MAILBOX_ADDRESS = ENV["MS_GRAPH_SHARED_MAILBOX_ADDRESS"] || "dummy@example.org"

# #  ALWAYS set the default mailbox so tests and app code don't see nil
# Rails.configuration.after_initialize do
#   Email.set_default_mailbox(
#     user_id: SHARED_MAILBOX_USER_ID,
#     name: SHARED_MAILBOX_NAME,
#     email_address: SHARED_MAILBOX_ADDRESS,
#   )
# end

# # Only configure a real Graph client if the feature is enabled AND we have creds
# if ENABLE_MS_GRAPH &&
#     ENV["MS_GRAPH_CLIENT_ID"].present? &&
#     ENV["MS_GRAPH_CLIENT_SECRET"].present? &&
#     ENV["MS_GRAPH_TENANT"].present?

#   configuration = MicrosoftGraph::ClientConfiguration.new(
#     tenant: ENV.fetch("MS_GRAPH_TENANT"),
#     client_id: ENV.fetch("MS_GRAPH_CLIENT_ID"),
#     client_secret: ENV.fetch("MS_GRAPH_CLIENT_SECRET"),
#     scope: "https://graph.microsoft.com/.default",
#     grant_type: "client_credentials",
#   )

#   authenticator  = MicrosoftGraph::ApplicationAuthenticator.new(configuration)
#   client_session = MicrosoftGraph::ClientSession.new(authenticator:)

#   MicrosoftGraph.client = MicrosoftGraph::Client.new(client_session)
# else
#   Rails.logger.info("[MSGraph] client not configured – gem loaded, but credentials/flag missing")
# end

# Always load so Zeitwerk can see the constants
require "microsoft_graph"

ENABLE_MS_GRAPH = ActiveModel::Type::Boolean.new.cast(ENV["ENABLE_MS_GRAPH"])

# Define safe defaults so specs and dev don’t crash if env is missing
SHARED_MAILBOX_USER_ID = ENV["MS_GRAPH_SHARED_MAILBOX_USER_ID"] || "dummy-user-id"
SHARED_MAILBOX_NAME    = ENV["MS_GRAPH_SHARED_MAILBOX_NAME"]    || "dummy-mailbox"
SHARED_MAILBOX_ADDRESS = ENV["MS_GRAPH_SHARED_MAILBOX_ADDRESS"] || "dummy@example.org"

if ENABLE_MS_GRAPH &&
    ENV["MS_GRAPH_CLIENT_ID"].present? &&
    ENV["MS_GRAPH_CLIENT_SECRET"].present? &&
    ENV["MS_GRAPH_TENANT"].present?

  configuration = MicrosoftGraph::ClientConfiguration.new(
    tenant: ENV.fetch("MS_GRAPH_TENANT"),
    client_id: ENV.fetch("MS_GRAPH_CLIENT_ID"),
    client_secret: ENV.fetch("MS_GRAPH_CLIENT_SECRET"),
    scope: "https://graph.microsoft.com/.default".freeze,
    grant_type: "client_credentials".freeze,
  )

  authenticator  = MicrosoftGraph::ApplicationAuthenticator.new(configuration)
  client_session = MicrosoftGraph::ClientSession.new(authenticator:)
  MicrosoftGraph.client = MicrosoftGraph::Client.new(client_session)

  Rails.logger.info("[MSGraph] client configured successfully")
else
  # Fallback for test/dev environments
  class NullGraphClient
    def get(*) = []
    def post(*) = {}
    def method_missing(*) = nil
  end

  MicrosoftGraph.client = NullGraphClient.new
  Rails.logger.info("[MSGraph] client not configured – using NullGraphClient")
end

# Always set default mailbox, even in test/dev
Rails.application.config.after_initialize do
  Email.set_default_mailbox(
    user_id: SHARED_MAILBOX_USER_ID,
    name: SHARED_MAILBOX_NAME,
    email_address: SHARED_MAILBOX_ADDRESS,
  )
end

Rails.application.config.to_prepare do
  Email.set_default_mailbox(
    user_id: SHARED_MAILBOX_USER_ID,
    name: SHARED_MAILBOX_NAME,
    email_address: SHARED_MAILBOX_ADDRESS,
  )
end
