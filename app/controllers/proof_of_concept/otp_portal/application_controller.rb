class ProofOfConcept::OtpPortal::ApplicationController < ProofOfConcept::ApplicationController

private

  def current_otp_user
    if session[:otp_user_id]
      OtpUser.find(session[:otp_user_id])
    end
  end

  def current_otp_user=(otp_user)
    session[:otp_user_id] = otp_user.id
  end

  def log_out_current_otp_user
    session.delete(:otp_user_id)
  end
end
