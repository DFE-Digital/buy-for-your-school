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
end
