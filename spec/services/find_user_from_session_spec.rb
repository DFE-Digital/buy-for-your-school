require "rails_helper"

RSpec.describe FindUserFromSession do
  describe "#call" do
    context "when a user exists with this DfE Sign-in UID" do
      it "returns the user record" do
        user = create(:user, dfe_sign_in_uid: "03f98d51-5a93-4caa-9ff2-07faff7351d2")
        session_hash = {"dfe_sign_in_uid" => "03f98d51-5a93-4caa-9ff2-07faff7351d2"}
        result = described_class.new(session_hash: session_hash).call
        expect(result).to eq(user)
      end
    end
  end
end
