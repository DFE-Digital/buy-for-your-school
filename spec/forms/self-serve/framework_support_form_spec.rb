RSpec.describe FrameworkSupportForm do
  let(:user) { create(:user, :one_supported_school) }

  describe "#data" do
    it "infers values from the user" do
      form = described_class.new(user:)

      expect(form.data).to eql(
        group: false,
        org_id: "100253",
        first_name: "first_name",
        last_name: "last_name",
        email: "test@test",
        user_id: user.id,
      )
    end
  end

  describe "#forward" do
    context "when authenticated with many schools" do
      let(:user) { create(:user, :many_supported_schools_and_groups) }

      it "org select > message" do
        form = described_class.new(user:, step: 3)
        form.forward
        expect(form.step).to be 7
      end
    end

    it "defaults to stepping forward" do
      form = described_class.new(user:, step: 3)
      form.forward
      expect(form.step).to be 4
    end
  end

  describe "#backward" do
    context "when authenticated with many schools" do
      let(:user) { create(:user, :many_supported_schools_and_groups) }

      it "message > org select" do
        form = described_class.new(user:, step: 7)
        form.backward
        expect(form.step).to be 3
      end
    end

    it "defaults to stepping backward" do
      form = described_class.new(user:, step: 2)
      form.backward
      expect(form.step).to be 1
    end
  end

  describe "#go_back" do
    let(:form) do
      described_class.new(user:, step: 2)
    end

    context "with a user" do
      it "defaults" do
        params = form.go_back

        expect(params).to be_a Hash

        expect(params[:back]).to be true
        expect(params[:step]).to be 2 # originating position when back link was clicked

        expect(params[:first_name]).to eql "first_name"
        expect(params[:last_name]).to eql "last_name"
        expect(params[:email]).to eql "test@test"

        expect(params[:user]).to be_nil
        expect(params[:messages]).to be_nil
      end
    end

    context "with a guest" do
      let(:user) { Guest.new }

      it "defaults" do
        params = form.go_back

        expect(params).to be_a Hash

        expect(params[:back]).to be true
        expect(params[:step]).to be 2 # originating position when back link was clicked

        expect(params[:first_name]).to be_nil
        expect(params[:last_name]).to be_nil
        expect(params[:email]).to be_nil

        expect(params[:user]).to be_nil
        expect(params[:messages]).to be_nil
      end
    end
  end
end
