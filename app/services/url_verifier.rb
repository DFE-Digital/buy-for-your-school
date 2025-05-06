class UrlVerifier
  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(ENV["FAF_WEBHOOK_SECRET"])
  end

  def self.verify_url(signed_url)
    verifier.verify(signed_url)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end
end
