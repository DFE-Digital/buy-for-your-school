# frozen_string_literal: true

require "notify/email"

# @example "Default" template
#
#   Emails::Document.new(recipient: @user, attachment: "path/to/file").call
#
#   Hello ((first name)) ((last name)),
#
#   ...
#
#   Download your document at: ((link_to_file))
#
#
class Emails::Document < Notify::Email
  option :attachment, Types::String

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
