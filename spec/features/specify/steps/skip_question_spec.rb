RSpec.feature "Skipping questions" do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:journey) { create(:journey, user:, category:) }
  let(:section) { create(:section, journey:) }
  let(:task) { create(:task, section:, title: "Task") }

  before do
    user_is_signed_in(user:)
  end

  context "when there is a single step" do
    before do
      create(:step, :number, task:)

      visit_journey
      click_on "Task"
    end

    it "has a skip button" do
      expect(page).to have_link "Skip for now"
    end

    context "when skipped" do
      before do
        click_on "Skip for now"
      end

      it "returns to the journey page" do
        expect(page).to have_a_journey_path
      end

      it "does not change the task status" do
        within "ul.app-task-list__items" do
          expect(find("strong.govuk-tag--grey")).to have_text "Not started"
        end
      end
    end
  end

  context "when there are multiple steps" do
    let!(:number_step) { create(:step, :number, task:, title: "Number step", order: 0) }
    let!(:checkbox_step) { create(:step, :checkbox, task:, title: "Checkbox step", order: 1) }
    let!(:radio_step) { create(:step, :radio, task:, title: "Radio step", order: 2) }

    before do
      visit_journey
    end

    it "has a skip button" do
      click_on "Task"
      expect(page).to have_link "Skip for now"
    end

    context "when all steps are unanswered" do
      context "when skipped" do
        before do
          click_on "Task"
          click_on "Skip for now"
        end

        it "takes you to the next unanswered step" do
          expect(find("legend.govuk-fieldset__legend--l")).to have_text "Checkbox step"
        end

        it "adds skipped step ID to task's skipped_ids" do
          expect(number_step.reload.skipped?).to be true
        end
      end
    end

    context "when only one step is unanswered" do
      before do
        create(:number_answer, step: number_step)
        create(:radio_answer, step: radio_step)
        click_on "Task"
        click_on "Continue answering these questions"
      end

      context "when skipped" do
        before do
          click_on "Skip for now"
        end

        it "returns to the task page" do
          expect(page).to have_a_task_path
        end
      end
    end

    context "when some steps are answered" do
      before do
        create(:number_answer, step: number_step)
        click_on "Task"
        click_on "Continue answering these questions"
      end

      it "returns to the task page on last step" do
        click_on "Skip for now"
        click_on "Skip for now"
        expect(page).to have_a_task_path
      end
    end

    context "when all steps are skipped" do
      before do
        number_step.skip!
        checkbox_step.skip!
        radio_step.skip!
        click_on "Task"
      end

      context "when skipped again" do
        it "goes back to the task page" do
          expect(page).to have_text "Number step"
          click_on "Skip for now"
          expect(page).to have_text "Checkbox step"
          click_on "Skip for now"
          expect(page).to have_text "Radio step"
          click_on "Skip for now"
          expect(page).to have_a_task_path
        end
      end

      context "when a skipped step is answered" do
        it "the skipped step ID is removed from task skipped_ids" do
          expect(number_step.skipped?).to be true
          fill_in "answer[response]", with: "1"
          click_continue
          expect(number_step.reload.skipped?).to be false
        end
      end
    end
  end
end
