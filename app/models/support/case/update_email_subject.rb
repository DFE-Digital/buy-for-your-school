class Support::Case::UpdateEmailSubject
  def initialize(email_ids:, to_case_id:, from_case_id: nil, mailbox: Email.default_mailbox)
    @email_ids = email_ids
    @from_case_id = from_case_id
    @to_case_id = to_case_id
    @mailbox = mailbox
  end

  def call
    Support::Email.where(id: email_ids).find_each do |email|
      process_email(email)
    end
  end

private

  def process_email(email)
    current_email_subject = email.subject
    new_email_subject = update_subject_with_case_ref(current_email_subject)

    return if current_email_subject == new_email_subject

    update_remote_email_subject(email, new_email_subject)
    update_local_email_subject(email, new_email_subject)
  rescue StandardError => e
    Rails.logger.error("UpdateEmailSubject failed for case=#{to_case.ref} email=#{email.id}: #{e.message}")
  end

  def update_subject_with_case_ref(subject)
    case_pattern = /\ACase\s+\d{6}\b/

    if subject.match?(case_pattern)
      subject.sub(case_pattern, "Case #{to_case.ref}")
    else
      "Case #{to_case.ref} - #{subject}"
    end
  end

  def from_case
    @from_case ||= Support::Case.find_by(id: from_case_id)
  end

  def to_case
    @to_case ||= Support::Case.find(to_case_id)
  end

  def update_local_email_subject(email, new_subject)
    email.update!(subject: new_subject)
  end

  def update_remote_email_subject(email, new_subject)
    MicrosoftGraph.client.update_message(
      user_id: mailbox.user_id,
      message_id: email.outlook_id,
      details: { subject: new_subject },
    )
  end

  attr_reader :email_ids, :from_case_id, :to_case_id, :mailbox
end
