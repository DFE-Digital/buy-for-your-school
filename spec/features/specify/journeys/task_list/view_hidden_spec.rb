RSpec.feature "Users can view the task list" do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:journey) { create(:journey, user:, category:) }
  let(:section) { create(:section, title: "section a", journey:) }

  let(:options) { [{ "value" => "School expert", "display_further_information" => true, "further_information_help_text" => "Explain why this is the case" }, { "value" => "External expert" }, { "value" => "none" }] }
  let(:additional_step_rules) { [{ "required_answer" => "School expert", "question_identifiers" => %w[1] }] }

  before do
    user_is_signed_in(user:)
  end

  context "when a task includes an initially HIDDEN step" do
    before do
      task_1 = create(:task, title: "Hidden field task", section:)
      task_2 = create(:task, title: "Shown field task", section:)
      create(:step, :radio, title: "Hidden field", task: task_1, hidden: true)
      create(:step, :radio, title: "Shown field", task: task_2)

      visit "/journeys/#{journey.id}"
    end

    it "does not appear in the task list" do
      expect(page).not_to have_content "Hidden field task"
      expect(page).to have_content "Shown field task"
    end

    context "when that step becomes visible" do
      before do
        task_1 = create(:task, title: "One additional question task", section:)
        create(
          :step,
          :radio,
          title: "What support do you have available?",
          task: task_1,
          options:,
          additional_step_rules:,
          contentful_id: 0,
          order: 0,
        )
        create(:step, :radio, title: "What colour is the sky?", task: task_1, hidden: true, contentful_id: 1, order: 1)
        create(:step, :radio, title: "What email address did you use?", task: task_1, contentful_id: 2, order: 2)

        visit "/journeys/#{journey.id}"
      end

      it "appears in the order defined in Contentful rather than at the end" do
        # Simulate the bug by changing the created_at to a time that incorrectly
        # puts the hidden record at the bottom of the list
        Step.find_by(title: "What support do you have available?").update!(created_at: 3.days.ago)
        Step.find_by(title: "What email address did you use?").update!(created_at: 2.days.ago)
        Step.find_by(title: "What colour is the sky?").update!(created_at: 1.day.ago)

        click_on "One additional question task"
        # /journeys/a8001581-f27c-4ac2-af8c-5dac7f70b22e/steps/df8f0382-e652-4f25-bf7d-58a433882c03
        expect(page).to have_a_step_path
        click_back
        # /journeys/a8001581-f27c-4ac2-af8c-5dac7f70b22e/tasks/a73ff7b4-483b-4cda-9063-424da9ea0593
        expect(page).to have_a_task_path
        # list of steps
        steps = find_all(".govuk-summary-list__row")
        within(".govuk-summary-list") do
          expect(steps[0]).to have_content "What support do you have available?"
          # Hidden field "What colour is the sky?" is correctly omitted at this point
          expect(steps[1]).to have_content "What email address did you use?"
        end

        # Answer the first question to unlock "What colour is the sky?"
        first(".govuk-summary-list__row").click_on "Change" # generic.button.change_answer
        choose "School expert"
        click_continue

        # We get taken to the next question so we go back to the task page
        # /journeys/a8001581-f27c-4ac2-af8c-5dac7f70b22e/steps/7923954a-1265-4bf8-8427-8f4dee4161c0
        expect(page).to have_a_step_path
        click_back
        # /journeys/a8001581-f27c-4ac2-af8c-5dac7f70b22e/tasks/a73ff7b4-483b-4cda-9063-424da9ea0593
        expect(page).to have_a_task_path

        # Check that "What colour is in the sky added to the correct place in the list"
        steps = find_all(".govuk-summary-list__row")
        within(".govuk-summary-list") do
          expect(steps[0]).to have_content "What support do you have available?"
          expect(steps[1]).to have_content "What colour is the sky?"
          expect(steps[2]).to have_content "What email address did you use?"
        end
      end
    end
  end

  context "when a section has only hidden tasks" do
    before do
      task_1 = create(:task, title: "Hidden field task", section:)
      create(:step, :radio, title: "Hidden field", task: task_1, hidden: true)

      visit "/journeys/#{journey.id}"
    end

    it "shows the section title" do
      within(".app-task-list") do
        expect(page).to have_content "section a"
      end
    end

    it "shows an empty section" do
      expect(find("ul.app-task-list__items")).to have_selector("li", count: 0)
    end
  end
end
