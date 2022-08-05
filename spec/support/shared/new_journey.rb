#
# A Journey with 3 sections
#
#   - The quantity of section tasks match the section position
#     + Each task has 3 steps with a mix of types
#       * A step is a statement when step and task position match
#       * A step is a question when step and task position do not match
#
RSpec.shared_context "with a journey" do
  let(:category) { create(:category) }
  let(:journey) { create(:journey, category:) }

  # Sections -------------------------------------------------------------------
  let(:section_1) do
    create(:section, journey:, title: "section_1", order: 0)
  end

  let(:section_2) do
    create(:section, journey:, title: "section_2", order: 1)
  end

  let(:section_3) do
    create(:section, journey:, title: "section_3", order: 2)
  end

  # Tasks ----------------------------------------------------------------------

  # Task 1 ----------------------------------------
  let(:section_1_task_1) do
    create(:task, section: section_1, title: "section_1_task_1", order: 0)
  end

  # Task 2 ----------------------------------------
  let(:section_2_task_1) do
    create(:task, section: section_2, title: "section_2_task_1", order: 0)
  end

  let(:section_2_task_2) do
    create(:task, section: section_2, title: "section_2_task_2", order: 1)
  end

  # Task 3 ----------------------------------------
  let(:section_3_task_1) do
    create(:task, section: section_3, title: "section_3_task_1", order: 0)
  end

  let(:section_3_task_2) do
    create(:task, section: section_3, title: "section_3_task_2", order: 1)
  end

  let(:section_3_task_3) do
    create(:task, section: section_3, title: "section_3_task_3", order: 2)
  end

  # Steps ----------------------------------------------------------------------

  # Step 1 ----------------------------------------
  let(:section_1_task_1_step_1_statement) do
    create(:step, :statement,
           task: section_1_task_1,
           title: "section_1_task_1_step_1_statement",
           order: 0)
  end

  let(:section_1_task_1_step_2_question) do
    create(:step, :number,
           task: section_1_task_1,
           title: "section_1_task_1_step_2_question",
           hidden: true,
           order: 1)
  end

  let(:section_1_task_1_step_3_question) do
    create(:step, :single_date,
           task: section_1_task_1,
           title: "section_1_task_1_step_3_question",
           order: 2)
  end

  # Step 2 ----------------------------------------
  let(:section_2_task_1_step_1_statement) do
    create(:step, :statement,
           task: section_2_task_1,
           title: "section_2_task_1_step_1_statement",
           order: 0)
  end

  let(:section_2_task_1_step_2_question) do
    create(:step, :number,
           task: section_2_task_1,
           title: "section_2_task_1_step_2_question",
           order: 1)
  end

  let(:section_2_task_1_step_3_question) do
    create(:step, :radio,
           task: section_2_task_1,
           title: "section_2_task_1_step_3_question",
           hidden: true,
           order: 2)
  end

  # Step 3 ----------------------------------------
  let(:section_2_task_2_step_1_question) do
    create(:step, :short_text,
           task: section_2_task_2,
           title: "section_2_task_2_step_1_question",
           order: 0)
  end

  let(:section_2_task_2_step_2_statement) do
    create(:step, :statement,
           task: section_2_task_2,
           title: "section_2_task_2_step_2_statement",
           hidden: true,
           order: 1)
  end

  let(:section_2_task_2_step_3_question) do
    create(:step, :short_text,
           task: section_2_task_2,
           title: "section_2_task_2_step_3_question",
           order: 2)
  end

  # Step 4 ----------------------------------------
  let(:section_3_task_1_step_1_statement) do
    create(:step, :statement,
           task: section_3_task_1,
           title: "section_3_task_1_step_1_statement",
           hidden: true,
           order: 0)
  end

  let(:section_3_task_1_step_2_question) do
    create(:step, :currency,
           task: section_3_task_1,
           title: "section_3_task_1_step_2_question",
           order: 1)
  end

  let(:section_3_task_1_step_3_question) do
    create(:step, :currency,
           task: section_3_task_1,
           title: "section_3_task_1_step_3_question",
           hidden: true,
           order: 2)
  end

  # Step 5 ----------------------------------------
  let(:section_3_task_2_step_1_question) do
    create(:step, :single_date,
           task: section_3_task_2,
           title: "section_3_task_2_step_1_question",
           order: 0)
  end

  let(:section_3_task_2_step_2_statement) do
    create(:step, :statement,
           task: section_3_task_2,
           title: "section_3_task_2_step_2_statement",
           order: 1)
  end

  let(:section_3_task_2_step_3_question) do
    create(:step, :checkbox,
           task: section_3_task_2,
           title: "section_3_task_2_step_3_question",
           order: 2)
  end

  # Step 6 ----------------------------------------
  let(:section_3_task_3_step_1_question) do
    create(:step, :long_text,
           task: section_3_task_3,
           title: "section_3_task_3_step_1_question",
           hidden: true,
           order: 0)
  end

  let(:section_3_task_3_step_2_question) do
    create(:step, :long_text,
           task: section_3_task_3,
           title: "section_3_task_3_step_2_question",
           order: 1)
  end

  let(:section_3_task_3_step_3_statement) do
    create(:step, :statement,
           task: section_3_task_3,
           title: "section_3_task_3_step_3_statement",
           order: 2)
  end

  # Assertions -----------------------------------------------------------------

  specify "a journey is created" do
    expect(Journey.count).to be 1
  end

  it "has an associated category" do
    expect(Category.count).to be 1
    expect(journey.category).to be_present
  end

  it "has associated sections" do
    expect(Section.count).to be 3
    expect(journey.sections.count).to be 3
  end

  it "has associated tasks" do
    expect(Task.count).to be 6
    expect(journey.tasks.count).to be 6
  end

  it "has associated steps" do
    expect(Step.count).to be 18
    expect(journey.steps.count).to be 18

    expect(Step.that_are_questions.count).to be 12
    expect(Step.that_are_statements.count).to be 6
  end
end
