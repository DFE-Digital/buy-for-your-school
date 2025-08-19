# config/initializers/microsoft_graph.rb
require "microsoft_graph"

# In test, default the flag to true so the sync code runs during specs.
ENABLE_MS_GRAPH = ActiveModel::Type::Boolean.new.cast(
  ENV.fetch("ENABLE_MS_GRAPH") { Rails.env.test? ? "true" : "false" },
)

# Always provide these constants so tests and app code can reference them
SHARED_MAILBOX_USER_ID = ENV["MS_GRAPH_SHARED_MAILBOX_USER_ID"] || "dummy-user-id"
SHARED_MAILBOX_NAME    = ENV["MS_GRAPH_SHARED_MAILBOX_NAME"]    || "dummy-mailbox"
SHARED_MAILBOX_ADDRESS = ENV["MS_GRAPH_SHARED_MAILBOX_ADDRESS"] || "dummy@example.org"

# Make sure the default mailbox is in place for every boot/reload
Rails.configuration.to_prepare do
  Email.set_default_mailbox(
    user_id: SHARED_MAILBOX_USER_ID,
    name: SHARED_MAILBOX_NAME,
    email_address: SHARED_MAILBOX_ADDRESS,
  )
end

# Only wire a real Microsoft Graph client if enabled AND creds exist
if ENABLE_MS_GRAPH &&
    ENV["MS_GRAPH_CLIENT_ID"].present? &&
    ENV["MS_GRAPH_CLIENT_SECRET"].present? &&
    ENV["MS_GRAPH_TENANT"].present?

  configuration = MicrosoftGraph::ClientConfiguration.new(
    tenant: ENV.fetch("MS_GRAPH_TENANT"),
    client_id: ENV.fetch("MS_GRAPH_CLIENT_ID"),
    client_secret: ENV.fetch("MS_GRAPH_CLIENT_SECRET"),
    scope: "https://graph.microsoft.com/.default",
    grant_type: "client_credentials",
  )

  authenticator  = MicrosoftGraph::ApplicationAuthenticator.new(configuration)
  client_session = MicrosoftGraph::ClientSession.new(authenticator:)
  MicrosoftGraph.client = MicrosoftGraph::Client.new(client_session)
else
  Rails.logger.info("[MSGraph] client not configured – gem loaded, but credentials/flag missing")
end
