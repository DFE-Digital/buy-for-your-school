class Support::Case::EmailTicketable::ExistingCase
  def self.create_by(email)
    Support::CreateCase.new(
      source: :incoming_email,
      email: email.sender_email,
      first_name: email.sender_first_name,
      last_name: email.sender_last_name,
    ).call
  end

  def self.find_by(email)
    new(email:).existing_case
  end

  def self.find_or_create_by(email)
    find_by(email) || create_by(email)
  end

  def initialize(email:)
    @email = email
  end

  def existing_case
    found_case = email.ticket || case_from_email_chain || case_from_subject_or_body_reference
    found_case.try(:closed?) ? nil : found_case
  end

private

  attr_reader :email

  def case_from_email_chain
    email.in_current_conversation.assigned_to_ticket.first.try(:case)
  end

  def case_from_subject_or_body_reference
    case_reference = email.subject.match(/([0-9]{6,6})/).to_a.last
    case_reference ||= email.body.match(/Your reference number is: ([0-9]{6,6})\./).to_a.last

    Support::Case.find_by(ref: case_reference)
  end
end
