OmniAuth.config.logger = Rails.logger

dfe_sign_in_issuer_uri = URI(ENV.fetch("DFE_SIGN_IN_ISSUER", "example"))
dfe_sign_in_identifier = ENV.fetch("DFE_SIGN_IN_IDENTIFIER", "example")
dfe_sign_in_secret = ENV.fetch("DFE_SIGN_IN_SECRET", "example")
dfe_sign_in_redirect_uri = ENV.fetch("DFE_SIGN_IN_REDIRECT_URL", "example")

dfe_sign_in_issuer_url = "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.port

dfe_specify_options = {
  name: :dfe,
  discovery: true,
  response_type: :code,
  issuer: dfe_sign_in_issuer_url,
  scope: %i[openid email profile organisationid],
  client_auth_method: :client_secret_post,
  client_options: {
    port: dfe_sign_in_issuer_uri.port,
    scheme: dfe_sign_in_issuer_uri.scheme,
    host: dfe_sign_in_issuer_uri.host,
    identifier: dfe_sign_in_identifier,
    secret: dfe_sign_in_secret,
    redirect_uri: dfe_sign_in_redirect_uri,
  },
}

dfe_support_sign_in_redirect_uri = ENV.fetch("DFE_SUPPORT_SIGN_IN_REDIRECT_URL", "example")

dfe_support_options = {
  name: :dfe_support,
  discovery: true,
  response_type: :code,
  issuer: dfe_sign_in_issuer_url,
  scope: %i[openid email profile organisationid],
  client_auth_method: :client_secret_post,
  callback_path: lambda do |env|
    env["REQUEST_PATH"].to_s.match(/\/support\/auth\/dfe\/callback/) || env["REQUEST_PATH"].to_s.match(/\/support\/auth\/dfe\/signout/)
  end,
  client_options: {
    port: dfe_sign_in_issuer_uri.port,
    scheme: dfe_sign_in_issuer_uri.scheme,
    host: dfe_sign_in_issuer_uri.host,
    identifier: dfe_sign_in_identifier,
    secret: dfe_sign_in_secret,
    redirect_uri: dfe_support_sign_in_redirect_uri,
  },
}

# @see PagesController.dsi?
if Rails.env.development? && (ENV["DFE_SIGN_IN_ENABLED"] == "false")
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :developer,
             fields: %i[uid],
             uid_field: :uid
  end
else
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect, dfe_specify_options
    provider :openid_connect, dfe_support_options
  end
end
