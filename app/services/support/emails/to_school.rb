# frozen_string_literal: true

require "notify/email"

module Support
  class Emails::ToSchool < Notify::Email
    def call
      Rollbar.info "Sending email to school"

      super
    end
  end
end
