require "rails_helper"

RSpec.describe JourneyHelper, type: :helper do
  describe "#section_group_with_steps" do
    it "returns an ordered array of steps" do
      journey = create(:journey, section_groups: "")
      section = create(:section, journey: journey)
      task = create(:task, section: section)
      step_1 = StepPresenter.new(create(:step, :radio, task: task))
      step_2 = StepPresenter.new(create(:step, :long_text, task: task))
      step_3 = StepPresenter.new(create(:step, :short_text, task: task))

      section_groups = [
        {
          "order" => 0,
          "title" => "Objectives",
          "steps" => [
            {
              "contentful_id" => step_1.contentful_id,
              "order" => 0
            },
            {
              "contentful_id" => step_2.contentful_id,
              "order" => 1
            }
          ]
        },
        {
          "order" => 1,
          "title" => "Social value",
          "steps" => [
            {
              "contentful_id" => step_3.contentful_id,
              "order" => 0
            }
          ]
        }
      ]
      journey.update(section_groups: section_groups)

      result = helper.section_group_with_steps(
        journey: journey, steps: [step_1, step_2, step_3]
      )

      expect(result.first["steps"]).to eq([step_1, step_2])
      expect(result.second["steps"]).to eq([step_3])
    end
  end

  context "when the ordering we want does not match the order saved in the database" do
    it "the ordering defined by 'order' is preserved" do
      journey = create(:journey, section_groups: "")
      section = create(:section, journey: journey)
      task = create(:task, section: section)
      step_1 = StepPresenter.new(create(:step, :radio, title: "First question", task: task))
      step_2 = StepPresenter.new(create(:step, :long_text, title: "Second question", task: task))
      step_3 = StepPresenter.new(create(:step, :short_text, title: "Third question", task: task))
      step_4 = StepPresenter.new(create(:step, :short_text, title: "Fourth question", task: task))

      section_groups = [
        {
          "order" => 1,
          "title" => "Objectives",
          "steps" => [
            {
              "contentful_id" => step_2.contentful_id,
              "order" => 2
            },
            {
              "contentful_id" => step_1.contentful_id,
              "order" => 1
            },
            {
              "contentful_id" => step_3.contentful_id,
              "order" => 3
            }
          ]
        },
        {
          "order" => 0,
          "title" => "Social value",
          "steps" => [
            {
              "contentful_id" => step_4.contentful_id,
              "order" => 0
            }
          ]
        }
      ]
      journey.update(section_groups: section_groups)

      result = helper.section_group_with_steps(
        journey: journey, steps: [step_1, step_2, step_3, step_4]
      )

      expect(result.first["steps"]).to eq([step_1, step_2, step_3])
      expect(result.second["steps"]).to eq([step_4])
    end
  end
end
