class ProofOfConcept::OtpPortal::SessionsController < ProofOfConcept::OtpPortal::ApplicationController
  before_action { @form = SessionForm.new(sessions_params) }

  def new; end

  def passcode
    if @form.valid?
      # only creating user for conveinince in POC - Dont do in production!
      otp_user = OtpUser.find_or_create_by(email: @form.email)
      otp_user.send_passcode_in_email
    else
      render :new
    end
  end

  def create
    if @form.valid?(context: :passcode_entry)
      self.current_otp_user = OtpUser.find_by(email: @form.email)

      redirect_to proof_of_concept_otp_portal_welcomes_path
    else
      render :passcode
    end
  end

  def destroy
    log_out_current_otp_user
    redirect_to proof_of_concept_otp_portal_path
  end

private

  def sessions_params
    params.fetch(:session, {}).permit(:email, :passcode)
  end

  class SessionForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :email, :passcode

    validates :email, presence: true
    validates :passcode, presence: true, on: :passcode_entry
    validate :passcode_is_correct, on: :passcode_entry

    def passcode_is_correct
      user = OtpUser.find_by(email:)

      unless user.authenticate_email_otp(otp_code: passcode)
        errors.add(:passcode, "Invalid code")
      end
    end
  end
end
