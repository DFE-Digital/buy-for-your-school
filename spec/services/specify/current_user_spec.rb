RSpec.describe CurrentUser do
  subject(:service) { described_class.new }

  let(:result) { service.call(uid: dfe_sign_in_uid) }

  let!(:user) do
    create(:user, dfe_sign_in_uid: "03f98d51-5a93-4caa-9ff2-07faff7351d2")
  end

  describe "#call" do
    context "when the session key contains the user dsi uid" do
      let(:dfe_sign_in_uid) { "03f98d51-5a93-4caa-9ff2-07faff7351d2" }

      it "returns the User" do
        expect(result).to eq user
      end
    end

    context "when the session key is empty" do
      let(:dfe_sign_in_uid) { nil }

      it "returns a Guest" do
        expect(result).to be_a Guest
      end
    end
  end
end
