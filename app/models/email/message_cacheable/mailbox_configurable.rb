module Email::MessageCacheable::MailboxConfigurable
  extend ActiveSupport::Concern

  def default_mailbox
    self.class.default_mailbox
  end

  class_methods do
    attr_reader :default_mailbox

    def set_default_mailbox(user_id:, name:, email_address:)
      @default_mailbox = OpenStruct.new(user_id:, name:, email_address:)
    end
  end
end
