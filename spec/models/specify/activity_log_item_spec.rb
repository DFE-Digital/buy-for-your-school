RSpec.describe ActivityLogItem, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:journey_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:action) }
  end

  describe "#to_csv" do
    it "includes headers" do
      expect(described_class.to_csv).to eql(
        "id,journey_id,user_id,contentful_category_id,contentful_section_id,contentful_task_id,contentful_step_id,action,data,created_at,updated_at,contentful_category,contentful_section,contentful_task,contentful_step\n",
      )
    end
  end
end
