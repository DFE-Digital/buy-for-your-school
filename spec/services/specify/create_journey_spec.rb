# CMS: CreateJourney deserves to be tested with a complex real-world scenario fixture
# TODO: expand on category-peter.json to mirror the complexity in shared context factories
RSpec.describe CreateJourney do
  subject(:service) { described_class.new(category:, user:, name:) }

  let(:category) do
    build(:category,
          title: "Complex Category",
          contentful_id: "category-peter") # contentful_id must match the stubbed fixture
  end

  let(:journey) { Journey.last }
  let(:user) { build(:user) }
  let(:name) { "test spec" }

  before do
    # spec/fixtures/contentful/001-categories/category-peter.json
    stub_contentful_category(fixture_filename: "category-peter.json")

    service.call
  end

  describe "#call" do
    it "creates a new journey" do
      expect { service.call }.to change(Journey, :count).by 1
      expect(Journey.count).to be 2
    end

    it "associates the journey with a category" do
      expect(journey.category.contentful_id).to eql "category-peter"
      expect(journey.category.title).to eql "Complex Category"
    end

    it "associates the journey with a user" do
      expect(journey.user).to eq user
    end

    it "creates associated sections in order" do
      expect(journey.sections.count).to be 3

      # spec/fixtures/contentful/002-sections/section-1-peter.json
      expect(journey.sections[0].contentful_id).to eql "section-1-peter"
      expect(journey.sections[0].order).to be 0

      # spec/fixtures/contentful/002-sections/section-2-peter.json
      expect(journey.sections[1].contentful_id).to eql "section-2-peter"
      expect(journey.sections[1].order).to be 1

      # spec/fixtures/contentful/002-sections/section-3-peter.json
      expect(journey.sections[2].contentful_id).to eql "section-3-peter"
      expect(journey.sections[2].order).to be 2
    end

    it "creates all associated tasks" do
      expect(journey.tasks.count).to be 9
      # spec/fixtures/contentful/002-tasks/every-question-type-task.json
      expect(journey.tasks[0].contentful_id).to eql "every-question-type-task"
    end

    it "creates associated tasks in order" do
      expect(journey.tasks[0].order).to be 0
      expect(journey.tasks[1].order).to be 0
      expect(journey.tasks[2].order).to be 0
      expect(journey.tasks[3].order).to be 1
      expect(journey.tasks[4].order).to be 1
      expect(journey.tasks[5].order).to be 1

      expect(journey.sections[0].tasks[0].order).to be 0
      expect(journey.sections[0].tasks[1].order).to be 1
      expect(journey.sections[0].tasks[2].order).to be 2
      expect(journey.sections[1].tasks[0].order).to be 0
      expect(journey.sections[1].tasks[1].order).to be 1
      expect(journey.sections[1].tasks[2].order).to be 2
    end

    # 3 sections * 3 tasks * 7 steps = 63
    it "creates associated steps in order" do
      expect(journey.steps.count).to be 63
    end

    # TODO: this test is applicable to the yet to be created CreateCategory service object
    # context "when the category cannot be saved" do
    #   # Force a validation error by not providing an invalid category ID
    #   let(:fixture) { "category-with-no-title" }

    #   it "raises an error" do
    #     expect { service.call }.to raise_error ActiveRecord::RecordInvalid
    #   end
    # end
  end
end
