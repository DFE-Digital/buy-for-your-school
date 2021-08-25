RSpec.describe CreateUser do
  subject(:service) { described_class.new(auth: omniauth_hash) }

  let(:result) { service.call }

  let!(:user) do
    create(:user, dfe_sign_in_uid: "03f98d51-5a93-4caa-9ff2-07faff7351d2")
  end

  let(:dfe_sign_in_uid) { "03f98d51-5a93-4caa-9ff2-07faff7351d2" }

  let(:omniauth_hash) do
    { "uid" => dfe_sign_in_uid }
  end

  before do
    dsi_client = instance_double(::Dsi::Client)
    allow(Dsi::Client).to receive(:new).and_return(dsi_client)
    allow(dsi_client).to receive(:roles)
    allow(dsi_client).to receive(:orgs)
  end

  describe "#call" do
    context "when a user with that DSI UUID already exists in the database" do
      it "returns the existing user record" do
        expect(result).to eq user
      end
    end

    context "when a user with that DSI UUID does not exist in the database" do
      let(:dfe_sign_in_uid) { "an-unknown-uuid" }

      it "creates a new user record" do
        expect(result).to eq User.find_by(dfe_sign_in_uid: "an-unknown-uuid")
      end
    end

    context "when the auth hash is missing the uid" do
      let(:omniauth_hash) do
        { "unexpected-key" => dfe_sign_in_uid }
      end

      it "returns false" do
        expect(result).to be false
      end
    end

    context "when the auth hash is missing" do
      let(:omniauth_hash) { nil }

      it "raises an error" do
        expect { result }.to raise_error Dry::Types::ConstraintError, /nil violates constraints/
      end
    end
  end
end
