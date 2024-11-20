module HasNormalizedEmail
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_email
  end

private

  def normalize_email
    email&.downcase!
  end
end
