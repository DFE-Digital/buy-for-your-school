# Use `dfe_sign_in_uid` to lookup User
#
class FindOrCreateUserFromSession
  # @return [Hash]
  attr_accessor :session_hash

  # @param session_hash [Hash] OmniAuth hash
  def initialize(session_hash:)
    self.session_hash = session_hash.with_indifferent_access
  end

  # @return [User]
  def call
    return nil unless session_hash.key?(:dfe_sign_in_uid)

    User.find_or_create_by!(dfe_sign_in_uid: session_hash[:dfe_sign_in_uid])
  end
end
