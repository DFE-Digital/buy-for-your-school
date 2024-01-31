require 'rails_helper'

describe OtpUser do
  let(:user) { described_class.new(otp_secret_key: described_class.otp_random_secret) }

  describe "#authenticate_email_otp" do
    context "when the otp_code was generated within the last 5 minutes" do
      let(:otp_code) { user.otp_code(time: (4.minutes + 30.seconds).ago) }

      it "fails the code under normal circumstances as it is over the default interval of 30 seconds" do
        # intentionally calling authenticate_otp
        expect(user.authenticate_otp(otp_code)).to eq(false)
      end

      it "accepts the code to allow 5 minutes for email users" do
        expect(user.authenticate_email_otp(otp_code:)).to eq(true)
      end

      it "allows use of the code only once" do
        expect(user.authenticate_email_otp(otp_code:)).to eq(true)
        expect(user.authenticate_email_otp(otp_code:)).to eq(false)
      end
    end

    context "when the otp_code was generated more than 5 minutes and 30 seconds ago (grace period to allow receipt of email)" do
      let(:otp_code) { user.otp_code(time: (5.minutes + 31.second).ago) }

      it "does not accept the code" do
        expect(user.authenticate_email_otp(otp_code:)).to eq(false)
      end
    end
  end
end
