RSpec.describe FrameworkSupportForm, type: :model do
  subject(:form) { described_class.new }

  describe "#to_h" do
    context "when populated" do
      subject(:form) do
        described_class.new(first_name: "Tester", email: "test@test.com", school_urn: "1234", message_body: "help", dsi: true)
      end

      it "has values" do
        expect(form.to_h).to eql({
          first_name: "Tester",
          email: "test@test.com",
          school_urn: "1234",
          message_body: "help",
        })
      end

      it "excludes dsi value" do
        expect(form.to_h).not_to have_key(:dsi)
      end
    end

    context "when unpopulated" do
      it "is empty" do
        expect(form.to_h).to be_empty
      end
    end
  end

  describe "#dsi?" do
    it "returns dsi value" do
      form = described_class.new(dsi: true)
      expect(form.dsi?).to be true

      form = described_class.new(dsi: false)
      expect(form.dsi?).to be false
    end
  end

  describe "#guest?" do
    it "returns flipped dsi value" do
      form = described_class.new(dsi: true)
      expect(form.guest?).to be false

      form = described_class.new(dsi: false)
      expect(form.guest?).to be true
    end
  end

  describe "#multiple_schools?" do
    it "returns group value" do
      form = described_class.new(group: true)
      expect(form.multiple_schools?).to be true

      form = described_class.new(group: false)
      expect(form.multiple_schools?).to be false
    end
  end

  describe "#forget_org" do
    context "when on form step 3" do
      context "and school is set" do
        subject(:form) do
          described_class.new(step: 3, school_urn: "1234", group_uid: "")
        end

        it "clears the group value" do
          form.forget_org
          expect(form.to_h).to eql({
            school_urn: "1234",
            group_uid: nil,
          })
        end
      end

      context "and group is set" do
        subject(:form) do
          described_class.new(step: 3, school_urn: "", group_uid: "4321")
        end

        it "clears the school value" do
          form.forget_org
          expect(form.to_h).to eql({
            school_urn: nil,
            group_uid: "4321",
          })
        end
      end
    end
  end
end
