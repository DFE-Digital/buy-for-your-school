class Email::Sendable::NullDelivery
  def self.deliver_as_new_message(draft); end

  def self.deliver_as_reply(draft); end
end
