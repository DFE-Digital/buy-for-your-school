RSpec.describe Journey, "#next_incomplete_task", type: :model do
  subject(:next_task) { journey.next_incomplete_task(current_task).title }

  include_context "with an incomplete journey"

  context "when all tasks are complete" do
    let(:current_task) { section_2_task_2 }

    it "returns nil" do
      # answer questions
      create(:single_date_answer, step: section_1_task_1_step_3_question)
      create(:radio_answer, step: section_2_task_1_step_3_question)
      create(:currency_answer, step: section_3_task_1_step_2_question)
      create(:currency_answer, step: section_3_task_1_step_3_question)
      create(:long_text_answer, step: section_3_task_3_step_1_question)
      create(:long_text_answer, step: section_3_task_3_step_2_question)

      # acknowledge statements
      journey.steps.that_are_statements.map(&:acknowledge!)

      expect(journey.next_incomplete_task(current_task)).to be_nil
    end
  end

  context "when the current task is incomplete" do
    let(:current_task) { section_1_task_1 }

    # section_1_task_1 -> section_1_task_1
    it "chooses the same task" do
      expect(next_task).to eql "section_1_task_1"
    end
  end

  context "when the current task is the first" do
    let(:current_task) { section_3_task_1 }

    # section_3_task_1 -> section_3_task_2
    it "chooses the next incomplete task in the current section" do
      create(:currency_answer, step: section_3_task_1_step_2_question)
      expect(next_task).to eql "section_3_task_2"
    end
  end

  context "when the current task is not the first" do
    let(:current_task) { section_3_task_2 }

    # section_3_task_2 -> section_3_task_3
    it "chooses the next incomplete task in the current section" do
      section_3_task_2_step_2_statement.acknowledge!
      expect(next_task).to eql "section_3_task_3"
    end
  end

  context "when the current section is completed" do
    let(:current_task) { section_1_task_1 }

    # section_1_task_1 -> section_2_task_1
    it "moves to the first task in the next immediate section" do
      create(:single_date_answer, step: section_1_task_1_step_3_question)
      expect(next_task).to eql "section_2_task_1"
    end

    # section_1_task_1 -> section_3_task_1
    it "moves to the first task in the next available section" do
      create(:single_date_answer, step: section_1_task_1_step_3_question)
      section_2_task_1_step_1_statement.acknowledge!
      expect(next_task).to eql "section_3_task_1"
    end
  end

  context "when the current section is completed but not all sections" do
    let(:current_task) { section_3_task_3 }

    # section_3_task_3 -> section_1_task_1
    it "chooses the first incomplete task in the first incomplete section" do
      create(:currency_answer, step: section_3_task_1_step_2_question)
      section_3_task_2_step_2_statement.acknowledge!
      create(:long_text_answer, step: section_3_task_3_step_2_question)
      section_3_task_3_step_3_statement.acknowledge!

      expect(next_task).to eql "section_1_task_1"
    end
  end
end
