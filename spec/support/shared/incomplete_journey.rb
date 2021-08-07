#
#                                         |           |        | Step     | Task
# Journey                                 | Completed | Hidden | Position | Position
#                                         |           |        |          |
# - section_1                             |           |        |          |
#   + section_1_task_1                    |           |        |          |  1
#     * section_1_task_1_step_1_statement |  x        |        |          |
#     * section_1_task_1_step_2_question  |  x        |  x     |          |
#     * section_1_task_1_step_3_question  |           |        |  1       |
#                                         |           |        |          |
# - section_2                             |           |        |          |
#   + section_2_task_1                    |           |        |          |  2
#     * section_2_task_1_step_1_statement |           |        |  2       |
#     * section_2_task_1_step_2_question  |  x        |        |          |
#     * section_2_task_1_step_3_question  |           |  x     |          |
#   + section_2_task_2                    |           |        |          |
#     * section_2_task_2_step_1_question  |  x        |        |          |
#     * section_2_task_2_step_2_statement |  x        |  x     |          |
#     * section_2_task_2_step_3_question  |  x        |        |          |
#                                         |           |        |          |
# - section_3                             |           |        |          |
#   + section_3_task_1                    |           |        |          |  3
#     * section_3_task_1_step_1_statement |  x        |  x     |          |
#     * section_3_task_1_step_2_question  |           |        |  3       |
#     * section_3_task_1_step_3_question  |           |  x     |          |
#   + section_3_task_2                    |           |        |          |  4
#     * section_3_task_2_step_1_question  |  x        |        |          |
#     * section_3_task_2_step_2_statement |           |        |  4       |
#     * section_3_task_2_step_3_question  |  x        |        |          |
#   + section_3_task_3                    |           |        |          |  5
#     * section_3_task_3_step_1_question  |           |  x     |          |
#     * section_3_task_3_step_2_question  |           |        |  5       |
#     * section_3_task_3_step_3_statement |           |        |  6       |
#
#
RSpec.shared_context "with an incomplete journey" do
  include_context "with a journey"

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

  it "has hidden steps" do
    expect(Step.hidden.count).to be 6
    expect(Step.that_are_questions.hidden.count).to be 4
    expect(Step.that_are_statements.hidden.count).to be 2
  end

  it "has completed steps" do
    expect(Step.that_are_questions.count(&:answered?)).to be 6
    expect(Step.that_are_statements.count(&:acknowledged?)).to be 3
  end
end
