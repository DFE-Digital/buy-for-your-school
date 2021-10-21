# frozen_string_literal: true

require "notify/email"

# @example "Default" template
#
#   Emails::Document.new(recipient: @user, attachment: "path/to/file").call
#
#   Hello ((first name)) ((last name)),
#   Download your document at: ((link_to_file))
#
#
class Emails::Document < Notify::Email
  # Override making this a required param
  option :attachment, Types::String

  def call
    Rollbar.info "Sending email"

    super
  end
end
