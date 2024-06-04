require "dry-initializer"

# Locate the authenticated person or return a guest entity
#
class CurrentUser
  extend Dry::Initializer

  # @!attribute [r] guest
  # @return [Guest] (defaults to new instance)
  option :guest, default: proc { Guest.new }

  # @param uid [String]
  #
  # @return [User, Guest]
  #
  def call(uid:)
    # TODO: lookup dsi uid from renamed table and check roles to infer user model
    return guest unless uid

    # Fallback to Guest if no user is found
    User.find_by(dfe_sign_in_uid: uid) || guest
  end
end
