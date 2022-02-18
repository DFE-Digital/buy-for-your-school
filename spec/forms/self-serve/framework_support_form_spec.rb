RSpec.describe FrameworkSupportForm do
  let(:user) { create(:user, :one_supported_school) }

  describe "#data" do
    it "infers values from the user" do
      form = described_class.new(user: user)

      expect(form.data).to eql(
        group: false,
        school_urn: "100253",
        first_name: "first_name",
        last_name: "last_name",
        email: "test@test",
        user_id: user.id,
      )
    end
  end

  describe "#forget_org" do
    context "when on step 3" do
      context "and school is set" do
        it "clears the group value" do
          form = described_class.new(user: user, step: 3, school_urn: "1234", group_uid: "")
          form.forget_org

          expect(form.to_h[:school_urn]).to eql "1234"
          expect(form.to_h[:group_uid]).to be_nil
        end
      end

      context "and group is set" do
        it "clears the school value" do
          form = described_class.new(user: user, step: 3, school_urn: "", group_uid: "4321")
          form.forget_org

          expect(form.to_h[:school_urn]).to be_nil
          expect(form.to_h[:group_uid]).to eql "4321"
        end
      end
    end

    context "when not on step 3" do
      context "and school is set" do
        it "clears the group value" do
          form = described_class.new(user: user, step: 99, school_urn: "1234", group_uid: "")
          form.forget_org

          expect(form.to_h[:school_urn]).to eql "1234"
          expect(form.to_h[:group_uid]).to eql ""
        end
      end

      context "and group is set" do
        it "clears the school value" do
          form = described_class.new(user: user, step: 99, school_urn: "", group_uid: "4321")
          form.forget_org

          expect(form.to_h[:school_urn]).to eql ""
          expect(form.to_h[:group_uid]).to eql "4321"
        end
      end
    end
  end

  describe "#forward" do
    context "when authenticated with many schools" do
      let(:user) { create(:user, :many_supported_schools_and_groups) }

      it "org select > message" do
        form = described_class.new(user: user, step: 3)
        form.forward
        expect(form.step).to be 7
      end
    end

    it "defaults to stepping forward" do
      form = described_class.new(user: user, step: 3)
      form.forward
      expect(form.step).to be 4
    end
  end

  describe "#backward" do
    context "when authenticated with many schools" do
      let(:user) { create(:user, :many_supported_schools_and_groups) }

      it "message > oerg select" do
        form = described_class.new(user: user, step: 7)
        form.backward
        expect(form.step).to be 3
      end
    end

    it "defaults to stepping backward" do
      form = described_class.new(user: user, step: 2)
      form.backward
      expect(form.step).to be 1
    end
  end
end
