class Support::Case::UpdateEmailSubject
  def initialize(email:, kase:, mailbox: Email.default_mailbox)
    @email   = email
    @kase    = kase
    @mailbox = mailbox
  end

  def call
    update_remote_email_subject!
    update_local_email_subject!
  end

private

  def update_remote_email_subject!
    MicrosoftGraph.client.update_message(
      user_id: mailbox.user_id,
      message_id: email.outlook_id,
      details: { subject: new_subject },
    )
  end

  def update_local_email_subject!
    email.update!(subject: new_subject)
  end

  def new_subject
    @new_subject ||= "Case: #{kase.ref} - #{email.subject}"
  end

  attr_reader :email, :kase, :mailbox
end
