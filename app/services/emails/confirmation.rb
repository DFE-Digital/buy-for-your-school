# frozen_string_literal: true

require "notify/email"

#
#   subject: Thank you for your request for help with a specification
#
#   Dear ((first name))
#
#   Thank you for submitting a request. We will be in touch to support you with
#   your specification within 5 days.
#
#   Your reference number is: ((ref number))
#
#   ^ Quote this number if you get in touch.
#
#   Read about buying for schools at https://www.gov.uk/guidance/buying-for-schools
#
#
# @example "Auto-reply" template
#
#   Emails::Confirmation.new(recipient: @user, template: "Auto-reply").call
#
class Emails::Confirmation < Notify::Email
  def call
    Rollbar.info "Sending email to #{recipient.email}"

    super
  end

  def template_params
    super.merge(ref_number: "")
  end
end
