class OtpUser < ApplicationRecord
  has_one_time_password after_column_name: :last_otp_at

  def send_passcode_in_email
    Emails::EmailPasscode.new(passcode: otp_code, recipient: self).call
  end

  def authenticate_email_otp(otp_code:)
    email_time_allowance_to_use_code = 5.minutes
    authenticate_otp(otp_code, drift: email_time_allowance_to_use_code)
  end
end
