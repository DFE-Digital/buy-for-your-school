RSpec.describe ActivityLogItem, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:journey_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:action) }
  end

  describe "#to_csv" do
    it "includes headers" do
      expect(described_class.to_csv).to eql(
        "id,action,contentful_category,contentful_category_id,contentful_section,contentful_section_id,contentful_step,contentful_step_id,contentful_task,contentful_task_id,created_at,data,journey_id,updated_at,user_id\n",
      )
    end
  end
end
