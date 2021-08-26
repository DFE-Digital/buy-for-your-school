# frozen_string_literal: true

require "notify/email"

class SendConfirmationEmail < Notify::Email
  def call
    Rollbar.info "Sending email to #{recipient.email}"

    super
  end

  def template_params
    super.merge(
      full_name: recipient.full_name,
    )
  end
end
