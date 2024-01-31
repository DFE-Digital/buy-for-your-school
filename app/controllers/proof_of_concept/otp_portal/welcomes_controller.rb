class ProofOfConcept::OtpPortal::WelcomesController < ProofOfConcept::OtpPortal::ApplicationController
  before_action { redirect_to new_proof_of_concept_otp_portal_sessions_path unless current_otp_user.present? }

  def show
    @back_url = proof_of_concept_otp_portal_path
  end
end
