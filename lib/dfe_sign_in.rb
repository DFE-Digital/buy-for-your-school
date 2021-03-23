module DfESignIn
  def self.bypass?
    Rails.env.development? && ENV["DFE_SIGN_IN_ENABLED"] == "false"
  end
end
