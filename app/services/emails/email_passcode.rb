require "notify/email"

class Emails::EmailPasscode < Notify::Email
  option :template, Types::String, default: proc { Support::EmailTemplates::IDS[:email_passcode] }
  option :passcode, Types::String

private

  def template_params
    { passcode: }
  end
end
