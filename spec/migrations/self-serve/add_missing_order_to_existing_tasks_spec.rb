require Rails.root.join("db/migrate/20210730083035_add_missing_order_to_existing_tasks")

RSpec.describe AddMissingOrderToExistingTasks do
  include_context "with data migrations"

  let(:previous_version) { 20_210_729_145_738 }
  let(:current_version) { 20_210_730_083_035 }

  context "when there are broken tasks" do
    before do
      ENV["POST_MIGRATION_CHANGES"] = "true"
      stub_contentful_category(fixture_filename: "section-with-multiple-tasks.json")

      # build and persist a category with no slug and no validation
      # as this column is not expected to exist yet
      category = build(:category, slug: nil)
      category.save!(validate: false)
      journey = create(:journey, category: category)
      # NB: section contentful_id needs to match the stubbed category fixture
      section = create(:section, contentful_id: "multiple-tasks-section", journey: journey)

      # NB: task contentful_ids need to match the stubbed section fixtures tasks array
      create(:task, title: "second", order: nil, section: section, contentful_id: "checkboxes-and-radio-task")
      create(:task, title: "third", order: nil, section: section, contentful_id: "every-question-type-task")
      create(:task, title: "first", order: nil, section: section, contentful_id: "checkboxes-task")
    end

    it "populates the order" do
      expect(Rollbar).to receive(:info)
          .with("Migration: Tasks with missing order",
                tasks_total: 3,
                tasks_updated: 3)

      expect { up }.to change { Task.where(order: nil).count }.from(3).to(0)

      expect(Task.where(title: "first").first.order).to eq 0
      expect(Task.where(title: "second").first.order).to eq 1
      expect(Task.where(title: "third").first.order).to eq 2
    end
  end
end
