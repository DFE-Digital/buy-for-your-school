require "jwt"

dsi_client_id = ENV["DSI_CLIENT_ID"]
dsi_client_secret = ENV["DSI_CLIENT_SECRET"]

payload = {
  iss: dsi_client_id,
  aud: "signin.education.gov.uk",
}

$stdout.print JWT.encode(payload, dsi_client_secret, "HS256")
