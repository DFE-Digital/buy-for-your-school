if Features.enabled?(:incoming_emails)
  require "microsoft_graph/microsoft_graph"

  configuration = MicrosoftGraph::ClientConfiguration.new(
    tenant: ENV.fetch("MS_GRAPH_TENANT"),
    client_id: ENV.fetch("MS_GRAPH_CLIENT_ID"),
    client_secret: ENV.fetch("MS_GRAPH_CLIENT_SECRET"),
    scope: "https://graph.microsoft.com/.default".freeze,
    grant_type: "client_credentials".freeze,
  )

  client_session = MicrosoftGraph::ClientSession.new(
    MicrosoftGraph::ApplicationAuthenticator.new(configuration),
  )

  MicrosoftGraph.client = MicrosoftGraph::Client.new(client_session)

  SHARED_MAILBOX_FOLDER_ID_INBOX = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_FOLDER_INBOX")
  SHARED_MAILBOX_FOLDER_ID_SENT_ITEMS = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_FOLDER_SENT_ITEMS")
  SHARED_MAILBOX_USER_ID = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_USER_ID")
end