require "dry-initializer"
require "guest"

# Locate the authenticated person or return a guest entity
#
module Support
  class CurrentAgent
    extend Dry::Initializer

    option :guest, default: proc { Guest.new }

    # @param uid [String]
    #
    # @return [Agent, Guest]
    #
    def call(uid:)
      # TODO: lookup dsi uid from renamed table and check roles to infer agent model
      return guest unless uid

      # Fallback to Guest if no user is found
      Agent.find_by(dfe_support_sign_in_uid: uid) || guest
    end
  end
end