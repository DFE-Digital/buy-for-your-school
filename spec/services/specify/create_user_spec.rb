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
      "extra" => {
        "raw_info" => {
          "organisation" => {
            "id" => "23F20E54-79EA-4146-8E39-18197576F023",
          },
        },
      },
    }
  end

  let(:orgs) do
    [{
      "id" => "23F20E54-79EA-4146-8E39-18197576F023",
      "type" => { "id" => ORG_TYPE_IDS.sample.to_s },
    }]
  end

  before do
    dsi_client = instance_double(::Dsi::Client)
    allow(Dsi::Client).to receive(:new).and_return(dsi_client)
    allow(dsi_client).to receive(:orgs).and_return(orgs)
  end

  describe "#call" do
    context "when a person with that DSI UUID already exists in the database" do
      it "returns the existing user record" do
        expect(result).to eq user
      end
    end

    context "when a person with that DSI UUID does not exist in the database" do
      let(:dfe_sign_in_uid) { "unknown-uuid" }

      let(:email) { "unknown@example.com" }

      it "creates a new user record" do
        expect(result).to eq User.find_by(dfe_sign_in_uid: "unknown-uuid")
      end
    end

    context "when they have updated their details" do
      let(:email) { "User@Example.com" }

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
        expect(result.first_name).to eq "New First"
        expect(result.last_name).to eq "New Last"
      end

      it "downcases the email" do
        expect(result.email).to eq("user@example.com")
      end
    end

    context "when the auth hash is missing the uid" do
      let(:omniauth_hash) do
        { "unexpected-key" => dfe_sign_in_uid }
      end

      it "is tagged :invalid" do
        expect(result).to be :invalid
      end
    end

    context "when the auth hash is missing" do
      let(:omniauth_hash) { nil }

      it "raises an error" do
        expect { result }.to raise_error Dry::Types::ConstraintError, /nil violates constraints/
      end
    end

    context "when they are in the ProcOps org" do
      let(:dfe_sign_in_uid) { "caseworker" }

      let(:orgs) do
        [{
          "id" => "23F20E54-79EA-4146-8E39-18197576F023",
          "name" => "DSI Caseworkers",
        }]
      end

      around do |example|
        ClimateControl.modify(PROC_OPS_TEAM: "DSI Caseworkers") do
          example.run
        end
      end

      it "creates a new user record" do
        expect(result).to eq User.find_by(dfe_sign_in_uid: "caseworker")
      end
    end

    context "when they already have a support agent record" do
      let(:dfe_sign_in_uid) { "something-else-4caa-9ff2-07faff7351d2" }
      let!(:existing_user) { create(:user, dfe_sign_in_uid:, email: email.upcase) }
      let!(:support_agent) { create(:support_agent, email: email.downcase) }
      let(:orgs) { [] }

      context "when the user already exists (regardless of org)" do
        it "returns the existing user" do
          expect(result).to eq existing_user
        end
      end

      context "when user does not exist already" do
        let(:dfe_sign_in_uid) { "something-else-again-ok-07faff7351d2" }

        it "creates a new user record" do
          expect(result).to eq User.find_by(dfe_sign_in_uid:)
        end

        it "downcases the email on the created user" do
          expect(result.email).to eq("user@example.com")
        end

        it "updates the agent to have the dsi uid of the user" do
          expect { service.call }.to change { support_agent.reload.dsi_uid }.to(dfe_sign_in_uid)
        end
      end
    end

    context "when there's an existing user" do
      context "and they are not affiliated to any organisation" do
        let(:orgs) { [] }

        it "is tagged :no_organisation" do
          expect(result).to be :no_organisation
        end
      end

      context "and they are affiliated to an unsupported organisation" do
        let(:orgs) do
          [{
            "id" => "23F20E54-79EA-4146-8E39-18197576F023",
            "type" => { "id" => "999" },
          }]
        end

        it "is tagged :unsupported" do
          expect(result).to be :unsupported
        end
      end
    end

    context "when there's a new user" do
      let(:dfe_sign_in_uid) { "new_user" }

      context "and they are not affiliated to any organisation" do
        let(:orgs) { [] }

        it "is tagged :no_organisation" do
          expect(result).to be :no_organisation
        end
      end

      context "and they are affiliated to an unsupported organisation" do
        let(:orgs) do
          [{
            "id" => "23F20E54-79EA-4146-8E39-18197576F023",
            "type" => { "id" => "999" },
          }]
        end

        it "is tagged :unsupported" do
          expect(result).to be :unsupported
        end
      end
    end

    context "when there's a support evaluator" do
      let(:dfe_sign_in_uid) { "evaluator-uid" }
      let(:email) { "evaluator@example.com" }
      let!(:support_evaluator) { create(:support_evaluator, email: email.downcase) }

      it "updates the support evaluator to have the dsi uid of the user" do
        service.call
        expect(support_evaluator.reload.dsi_uid).to eq(dfe_sign_in_uid)
      end
    end
  end
end
