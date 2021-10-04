RSpec.describe CreateUser do
  subject(:service) { described_class.new(auth: omniauth_hash) }

  let(:result) { service.call }

  let!(:user) do
    create(:user, dfe_sign_in_uid: "03f98d51-5a93-4caa-9ff2-07faff7351d2")
  end

  let(:dfe_sign_in_uid) { "03f98d51-5a93-4caa-9ff2-07faff7351d2" }
  let(:email) { "user@example.com" }

  let(:omniauth_hash) do
    {
      "uid" => dfe_sign_in_uid,
      "info" => {
        "email" => email,
      },
    }
  end

  before do
    dsi_client = instance_double(::Dsi::Client)
    allow(Dsi::Client).to receive(:new).and_return(dsi_client)
    allow(dsi_client).to receive(:roles).and_return([{}])
    allow(dsi_client).to receive(:orgs).and_return([{}])
  end

  describe "#call" do
    context "when a user with that DSI UUID already exists in the database" do
      it "returns the existing user record" do
        expect(result).to eq user
      end

      it "reports to Rollbar" do
        expect(Rollbar).to receive(:info).with("Updated account for user@example.com").and_call_original

        result
      end
    end

    context "when a user with that DSI UUID does not exist in the database" do
      let(:dfe_sign_in_uid) { "an-unknown-uuid" }
      let(:email) { "unknown@example.com" }

      it "creates a new user record" do
        expect(result).to eq User.find_by(dfe_sign_in_uid: "an-unknown-uuid")
      end

      it "reports to Rollbar" do
        expect(Rollbar).to receive(:info).with("Created account for unknown@example.com").and_call_original

        result
      end
    end

    context "when the user has updated their details" do
      let(:omniauth_hash) do
        {
          "uid" => dfe_sign_in_uid,
          "info" => {
            "first_name" => "New First",
            "last_name" => "New Last",
            "email" => email,
          },
        }
      end

      it "updates the user record" do
        expect(Rollbar).to receive(:info).with("Updated account for user@example.com").and_call_original

        expect(result.first_name).to eq "New First"
        expect(result.last_name).to eq "New Last"
      end
    end

    context "when a user has no roles or organisation in the DSI" do
      before do
        dsi_client = instance_double(::Dsi::Client)
        allow(Dsi::Client).to receive(:new).and_return(dsi_client)
        allow(dsi_client).to receive(:roles).and_raise(::Dsi::Client::ApiError)
        allow(dsi_client).to receive(:orgs).and_raise(::Dsi::Client::ApiError)
      end

      it "raises no error" do
        expect { result }.not_to raise_error
      end

      it "reports to Rollbar" do
        expect(Rollbar).to receive(:info).with("User 03f98d51-5a93-4caa-9ff2-07faff7351d2 has no organisation").and_call_original
        expect(Rollbar).to receive(:info).with("User 03f98d51-5a93-4caa-9ff2-07faff7351d2 has no roles").and_call_original
        expect(Rollbar).to receive(:info).with("Updated account for user@example.com").and_call_original

        result
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
