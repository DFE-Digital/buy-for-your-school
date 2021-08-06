# A Journey with 3 sections
#
#   - The quantity of section tasks match the section position
#
#     + Each task has 3 steps with a mix of types
#
#       * A step is a statement when step and task position match
#       * A step is a question when step and task position do not match
#
RSpec.shared_context "with an incomplete journey" do
  #
  #                                           |           |        | Step     | Task
  # Journey                                   | Completed | Hidden | Position | Position
  #                                           |           |        |          |
  #   - section_1                             |           |        |          |
  #     + section_1_task_1                    |           |        |          |  1
  #       * section_1_task_1_step_1_statement |  x        |        |          |
  #       * section_1_task_1_step_2_question  |  x        |  x     |          |
  #       * section_1_task_1_step_3_question  |           |        |  1       |
  #                                           |           |        |          |
  #   - section_2                             |           |        |          |
  #     + section_2_task_1                    |           |        |          |  2
  #       * section_2_task_1_step_1_statement |           |        |  2       |
  #       * section_2_task_1_step_2_question  |  x        |        |          |
  #       * section_2_task_1_step_3_question  |           |  x     |          |
  #     + section_2_task_2                    |           |        |          |
  #       * section_2_task_2_step_1_question  |  x        |        |          |
  #       * section_2_task_2_step_2_statement |  x        |  x     |          |
  #       * section_2_task_2_step_3_question  |  x        |        |          |
  #                                           |           |        |          |
  #   - section_3                             |           |        |          |
  #     + section_3_task_1                    |           |        |          |  3
  #       * section_3_task_1_step_1_statement |  x        |  x     |          |
  #       * section_3_task_1_step_2_question  |           |        |  3       |
  #       * section_3_task_1_step_3_question  |           |  x     |          |
  #     + section_3_task_2                    |           |        |          |  4
  #       * section_3_task_2_step_1_question  |  x        |        |          |
  #       * section_3_task_2_step_2_statement |           |        |  4       |
  #       * section_3_task_2_step_3_question  |  x        |        |          |
  #     + section_3_task_3                    |           |        |          |  5
  #       * section_3_task_3_step_1_question  |           |  x     |          |
  #       * section_3_task_3_step_2_question  |           |        |  5       |
  #       * section_3_task_3_step_3_statement |           |        |  6       |

  let(:category) { create(:category) }
  let(:journey) { create(:journey, category: category) }

  # Sections -------------------------------------------------------------------
  let(:section_1) { create(:section, journey: journey, title: "section_1", order: 0) }
  let(:section_2) { create(:section, journey: journey, title: "section_2", order: 1) }
  let(:section_3) { create(:section, journey: journey, title: "section_3", order: 2) }

  # Tasks ----------------------------------------------------------------------

  # 1 ----------------------------------------
  let(:section_1_task_1) do
    create(:task, section: section_1, title: "section_1_task_1", order: 0)
  end

  # 2 ----------------------------------------
  let(:section_2_task_1) do
    create(:task, section: section_2, title: "section_2_task_1", order: 0)
  end

  let(:section_2_task_2) do
    create(:task, section: section_2, title: "section_2_task_2", order: 1)
  end

  # 3 ----------------------------------------
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

  # 1 ----------------------------------------
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

  # 2 ----------------------------------------
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

  # 3 ----------------------------------------
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

  # 4 ----------------------------------------
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

  # 5 ----------------------------------------
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

  # 6 ----------------------------------------
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

  # Answer questions and acknowledge statements --------------------------------
  #
  before do
    # Section 1 - Task 1
    section_1_task_1_step_1_statement.acknowledge!
    create(:number_answer, step: section_1_task_1_step_2_question)
    section_1_task_1_step_3_question

    # Section 2 - Task 1
    section_2_task_1_step_1_statement
    create(:number_answer, step: section_2_task_1_step_2_question)
    section_2_task_1_step_3_question

    # Section 2 - Task 2
    create(:short_text_answer, step: section_2_task_2_step_1_question)
    section_2_task_2_step_2_statement.acknowledge!
    create(:short_text_answer, step: section_2_task_2_step_3_question)

    # Section 3 - Task 1
    section_3_task_1_step_1_statement.acknowledge!
    section_3_task_1_step_2_question
    section_3_task_1_step_3_question

    # Section 3 - Task 2
    create(:single_date_answer, step: section_3_task_2_step_1_question)
    section_3_task_2_step_2_statement
    create(:checkbox_answers, step: section_3_task_2_step_3_question)

    # Section 3 - Task 3
    section_3_task_3_step_1_question
    section_3_task_3_step_2_question
    section_3_task_3_step_3_statement
  end

  it "shared set is complete" do
    expect(Category.count).to be 1
    expect(Journey.count).to be 1
    expect(Section.count).to be 3
    expect(Task.count).to be 6

    expect(Step.count).to be 18
    expect(Step.that_are_questions.count).to be 12
    expect(Step.that_are_statements.count).to be 6

    # hidden
    expect(Step.that_are_questions.hidden.count).to be 4
    expect(Step.that_are_statements.hidden.count).to be 2
    expect(Step.hidden.count).to be 6

    # complete
    expect(Step.that_are_questions.count(&:answered?)).to be 6
    expect(Step.that_are_statements.count(&:acknowledged?)).to be 3
  end
end
