RSpec.describe Journey, "#next_incomplete_section", type: :model do
  subject(:next_section) { journey.next_incomplete_section(current_section).title }

  let(:current_section) { section_1 }

  include_context "with an incomplete journey"

  context "when all sections are complete" do
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

      expect(journey.next_incomplete_section(current_section)).to be_nil
    end
  end

  context "when the current section is not complete" do
    it "returns the next immediate incomplete section" do
      expect(next_section).to eql "section_2"
    end
  end

  context "when the current section is complete" do
    it "returns the next immediate incomplete section" do
      create(:single_date_answer, step: section_1_task_1_step_3_question)

      expect(next_section).to eql "section_2"
    end

    it "skips to the next available incomplete section" do
      create(:single_date_answer, step: section_1_task_1_step_3_question)
      section_2_task_1_step_1_statement.acknowledge!
      create(:radio_answer, step: section_2_task_1_step_3_question)

      expect(next_section).to eql "section_3"
    end
  end
end
