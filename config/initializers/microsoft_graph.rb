if ENV["MS_GRAPH_CLIENT_ID"].present?
  require "microsoft_graph/microsoft_graph"

  live_configuration = MicrosoftGraph::ClientConfiguration.new(
    tenant: ENV.fetch("MS_GRAPH_TENANT"),
    client_id: ENV.fetch("MS_GRAPH_CLIENT_ID"),
    client_secret: ENV.fetch("MS_GRAPH_CLIENT_SECRET"),
    scope: "https://graph.microsoft.com/.default".freeze,
    grant_type: "client_credentials".freeze,
  )

  test_configuration = MicrosoftGraph::ClientConfiguration.new(
    tenant: ENV.fetch("TEST_MS_GRAPH_TENANT"),
    client_id: ENV.fetch("TEST_MS_GRAPH_CLIENT_ID"),
    client_secret: ENV.fetch("TEST_MS_GRAPH_CLIENT_SECRET"),
    scope: "https://graph.microsoft.com/.default".freeze,
    grant_type: "client_credentials".freeze,
  )

  live_client_session = MicrosoftGraph::ClientSession.new(
    MicrosoftGraph::ApplicationAuthenticator.new(live_configuration),
  )

  test_client_session = MicrosoftGraph::ClientSession.new(
    MicrosoftGraph::ApplicationAuthenticator.new(test_configuration),
  )

  MicrosoftGraph.mail = MicrosoftGraph::Client::Mail.new(live_client_session)
  MicrosoftGraph.files = MicrosoftGraph::Client::Files.new(test_client_session, ENV.fetch("TEST_MS_GRAPH_SHAREPOINT_SITE_ID"), ENV.fetch("TEST_MS_GRAPH_SHAREPOINT_DRIVE_ID"), ENV.fetch("TEST_MS_GRAPH_SHAREPOINT_TEMPLATE_FOLDER_ID"))

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
