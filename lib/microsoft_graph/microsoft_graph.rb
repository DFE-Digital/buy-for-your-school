require "dry-initializer"
require "dry-types"
require "dry-transformer"
require "dry/transformer"
require "dry-inflector"
require "httparty"
require "active_support"
require "active_support/core_ext"

module Types
  include Dry.Types

  def self.DryConstructor(klass)
    Types.Constructor(klass) { |values| klass.new(**values) }
  end
end

module MicrosoftGraph
  def self.client=(client)
    @client = client
  end

  def self.client
    @client
  end
end

require_relative "transformer/all"
require_relative "resource/all"
require_relative "application_authenticator"
require_relative "client_configuration"
require_relative "client_session"
require_relative "client"
