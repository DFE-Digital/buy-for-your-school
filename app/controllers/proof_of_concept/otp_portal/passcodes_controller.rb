class ProofOfConcept::OtpPortal::PasscodesController < ProofOfConcept::OtpPortal::ApplicationController
  def show
    @back_url = proof_of_concept_otp_portal_path
    
    # only creating user for conveinince in POC - Dont do in production!
    otp_user = OtpUser.find_or_create_by!(email: current_user.email)
    @code = otp_user.otp_code
  end
end
