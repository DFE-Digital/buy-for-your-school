module MicrosoftGraph
  class Client::Files
    include Client::Queryable

    attr_reader :client_session

    DRIVE_ITEM_SELECT_FIELDS = %w[
      id
      name
      lastModifiedDateTime
      lastModifiedBy
      webUrl
    ].freeze

    def initialize(client_session, site_id, drive_id, template_folder_id)
      @client_session = client_session
      @site_id = site_id
      @drive_id = drive_id
      @template_folder_id = template_folder_id
    end

    # https://learn.microsoft.com/en-us/graph/api/site-get?view=graph-rest-1.0&tabs=http
    def site
      client_session.graph_api_get("/sites/root:/sites/GHBSSchoolCollab", multiple_results: false)
    end

    def drive
      client_session.graph_api_get("/sites/#{@site_id}/drive", multiple_results: false)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-copy?view=graph-rest-1.0&tabs=http
    def copy(name, original_item_id = @template_folder_id)
      request_body = {
        name:,
      }.to_json

      http_headers = {
        "Content-Type" => "application/json",
      }

      response = client_session.graph_api_post("/sites/#{@site_id}/drive/items/#{original_item_id}/copy", request_body, http_headers)
      response.headers.fetch("location")
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-list-children?view=graph-rest-1.0&tabs=http
    def list_root_drive_children
      query = Array(query)
        .push("$select=#{DRIVE_ITEM_SELECT_FIELDS.join(',')}")
      results = client_session.graph_api_get("/sites/#{@site_id}/drive/items/root/children".concat(format_query(query)))
      Transformer::DriveItem.transform_collection(results.body, into: Resource::DriveItem)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-list-children?view=graph-rest-1.0&tabs=http
    def list_child_items(item_id)
      query = Array(query)
        .push("$select=#{DRIVE_ITEM_SELECT_FIELDS.join(',')}")
      results = client_session.graph_api_get("/sites/#{@site_id}/drive/items/#{item_id}/children".concat(format_query(query)))
      Transformer::DriveItem.transform_collection(results.body, into: Resource::DriveItem)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-search?view=graph-rest-1.0&tabs=http
    def search_drive_items(search_text)
      results = client_session.graph_api_get("/sites/#{@site_id}/drive/root/search(q='#{search_text}')")
      Transformer::DriveItem.transform_collection(results.body, into: Resource::DriveItem)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-get?view=graph-rest-1.0&tabs=http
    def get_item(item_id)
      query = Array(query)
        .push("$select=#{DRIVE_ITEM_SELECT_FIELDS.join(',')}")
      response = client_session.graph_api_get("/sites/#{@site_id}/drive/items/#{item_id}".concat(format_query(query)), multiple_results: false)
      Transformer::DriveItem.transform(response.body, into: Resource::DriveItem)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-list-versions?view=graph-rest-1.0&tabs=http
    def list_versions(item_id)
      results = client_session.graph_api_get("/sites/#{@site_id}/drive/items/#{item_id}/versions")
      Transformer::DriveItemVersion.transform_collection(results.body, into: Resource::DriveItemVersion)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-createlink?view=graph-rest-1.0&tabs=http
    def create_sharing_link(item_id, type = "edit", scope = "anonymous")
      body = {
        type:,
        scope:,
      }.to_json

      http_headers = {
        "Content-Type" => "application/json",
      }

      result = client_session.graph_api_post("/sites/#{@site_id}/drive/items/#{item_id}/createLink", body, http_headers)
      result.body.dig("link", "webUrl")
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-invite?view=graph-rest-1.0&tabs=http
    def add_permissions(item_id, recipients = [], roles = %w[write])
      body = {
        requireSignIn: false,
        sendInvitation: true,
        roles:,
        recipients: recipients.map { |recipient| { email: recipient } },
        message: "test share",
      }.to_json

      http_headers = {
        "Content-Type" => "application/json",
      }

      client_session.graph_api_post("/sites/#{@site_id}/drive/items/#{item_id}/invite", body, http_headers)
    end

    # https://learn.microsoft.com/en-us/graph/api/permission-grant?view=graph-rest-1.0&tabs=http
    def grant_permissions(sharing_url, recipients = [], roles = %w[write])
      encoded_sharing_url = "u!#{Base64.urlsafe_encode64(sharing_url, padding: false).sub(/=*\z/, '')}"
      body = {
        recipients: recipients.map { |recipient| { email: recipient } },
        roles:,
      }.to_json

      http_headers = {
        "Content-Type" => "application/json",
      }

      client_session.graph_api_post("/shares/#{encoded_sharing_url}/permission/grant", body, http_headers)
    end

    # https://learn.microsoft.com/en-us/graph/api/invitation-post?view=graph-rest-1.0&tabs=http
    def create_guest_invitation(full_name, email, redirect_url = "https://localhost:3000")
      body = {
        invitedUserDisplayName: full_name,
        invitedUserEmailAddress: email,
        inviteRedirectUrl: redirect_url,
        sendInvitationMessage: true,
      }.to_json

      http_headers = {
        "Content-Type" => "application/json",
      }

      client_session.graph_api_post("/invitations", body, http_headers)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-checkout?view=graph-rest-1.0&tabs=http
    def check_out(item_id)
      client_session.graph_api_post("/sites/#{@site_id}/drive/items/#{item_id}/checkout", nil)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-put-content?view=graph-rest-1.0&tabs=http
    def replace_item(item_id, _file)
      http_headers = {
        "Content-Type" => "text/plain",
      }

      client_session.graph_api_put("/sites/#{@site_id}/drive/items/#{item_id}/content", body, http_headers)
    end

    # https://learn.microsoft.com/en-us/graph/api/driveitem-checkin?view=graph-rest-1.0&tabs=http
    def check_in(item_id, _comment)
      body = {
        comment:,
      }.to_json

      http_headers = {
        "Content-Type" => "application/json",
      }

      client_session.graph_api_post("/sites/#{@site_id}/drive/items/#{item_id}/checkin", body, http_headers)
    end
  end
end
