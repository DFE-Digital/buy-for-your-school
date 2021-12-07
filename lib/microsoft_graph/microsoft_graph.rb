require "dry-initializer"
require "dry-types"
require "httparty"
require "active_support"
require "active_support/core_ext"

module Types
  include Dry.Types
end

require_relative "resource/attachment"
require_relative "resource/email_address"
require_relative "resource/item_body"
require_relative "resource/recipient"
require_relative "resource/message"
require_relative "resource/mail_folder"
require_relative "application_authenticator"
require_relative "client_configuration"
require_relative "client_session"
require_relative "client"
