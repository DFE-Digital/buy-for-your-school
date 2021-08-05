RSpec.describe FindOrCreateUserFromSession do
  subject(:service) do
    described_class.new(session_hash: session_hash)
  end

  let!(:user) do
    create(:user, dfe_sign_in_uid: dfe_sign_in_uid)
  end

  let(:dfe_sign_in_uid) { "03f98d51-5a93-4caa-9ff2-07faff7351d2" }

  let(:session_hash) do
    { "dfe_sign_in_uid" => dfe_sign_in_uid }
  end

  describe "#call" do
    context "when a user exists with this DfE Sign-in UID" do
      it "returns the user record" do
        expect(service.call).to eq user
      end
    end

    context "when a user does not exist with this DfE Sign-in UID" do
      let(:dfe_sign_in_uid) { "an-unknown-uuid" }

      it "creates a new user record" do
        expect(service.call).to eq User.find_by(dfe_sign_in_uid: "an-unknown-uuid")
      end
    end

    context "when the session_hash includes an unexpected key" do
      let(:session_hash) do
        { "unexpected-key" => dfe_sign_in_uid }
      end

      it "returns false" do
        expect(service.call).to be false
      end
    end
  end
end
