if ENV["MS_GRAPH_CLIENT_ID"].present?
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

  SHARED_MAILBOX_USER_ID = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_USER_ID")
  SHARED_MAILBOX_NAME = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_NAME")
  SHARED_MAILBOX_ADDRESS = ENV.fetch("MS_GRAPH_SHARED_MAILBOX_ADDRESS")

  Rails.configuration.to_prepare do
    Email.set_default_mailbox(
      user_id: ENV.fetch("MS_GRAPH_SHARED_MAILBOX_USER_ID"),
      name: ENV.fetch("MS_GRAPH_SHARED_MAILBOX_NAME"),
      email_address: ENV.fetch("MS_GRAPH_SHARED_MAILBOX_ADDRESS"),
    )

    Email.on_new_message_cached_handlers.add ->(email) { EmailAttachment.delete_draft_attachments_for_email(email) }
    Email.on_new_message_cached_handlers.add ->(email) { EmailAttachment.cache_attachments_for_email(email) }
    Email.on_new_message_cached_handlers.add ->(email) { Frameworks::Evaluation.on_email_cached(email) }
    Email.on_new_message_cached_handlers.add ->(email) { Support::Case.on_email_cached(email) }
  end
end
