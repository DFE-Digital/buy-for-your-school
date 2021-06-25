require "rails_helper"

RSpec.describe FindOrCreateUserFromSession do
  describe "#call" do
    context "when a user exists with this DfE Sign-in UID" do
      it "returns the user record" do
        user = create(:user, dfe_sign_in_uid: "03f98d51-5a93-4caa-9ff2-07faff7351d2")
        session_hash = { "dfe_sign_in_uid" => "03f98d51-5a93-4caa-9ff2-07faff7351d2" }
        result = described_class.new(session_hash: session_hash).call
        expect(result).to eq(user)
      end
    end

    context "when a user doesn't exist with this DfE Sign-in UID" do
      it "creates a new user record" do
        session_hash = { "dfe_sign_in_uid" => "an-unknown-uuid" }
        result = described_class.new(session_hash: session_hash).call
        user = User.find_by(dfe_sign_in_uid: "an-unknown-uuid")
        expect(result).to eq(user)
      end
    end

    context "when the session_hash does not include an expected key" do
      it "returns nil" do
        session_hash = { "unexpected-key" => "03f98d51-5a93-4caa-9ff2-07faff7351d2" }
        result = described_class.new(session_hash: session_hash).call
        expect(result).to eq(nil)
      end
    end
  end
end
