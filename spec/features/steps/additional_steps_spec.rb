RSpec.feature "Toggling additional steps" do
  let(:step) { create(:step, :additional_steps) }
  let(:journey) { step.task.section.journey }
  let(:user) { journey.user }

  describe "in the journey" do
    context "when there are hidden steps" do
      before do
        # build dependent steps (used by additional_steps trait)
        create(:step, :statement,
               contentful_id: "123",
               order: 1,
               title: "statement!",
               hidden: true,
               task: step.task)

        create(:step, :short_text,
               contentful_id: "456",
               order: 2,
               title: "question?",
               hidden: true,
               task: step.task)

        user_is_signed_in(user: user)
        visit journey_path(journey)
      end

      it "changes the state badge" do
        # enter task and be taken to additional step question
        click_on "Task title"

        # answer question revealing additional steps
        choose "yes"
        click_on "Continue"

        # continue to newly revealed statement step
        within ".govuk-body" do
          expect(find("h2")).to have_text "Heading 2"
        end
        # acknowledge the statement
        click_on "Continue"

        # FIXME: continue to newly revealed question step
        # expect(find("label.govuk-label--l")).to have_text "question?"

        # list of steps
        expect(page).to have_text "statement!"
        expect(page).to have_text "question?"

        # go back
        click_on "Return to task list"
        # list of tasks
        expect(find("strong.app-task-list__tag")).to have_text "In progress"
      end
    end

    context "when there are no additional steps" do
      before do
        user_is_signed_in(user: user)
        visit journey_path(journey)
      end

      it "does not change the state badge" do
        click_on "Task title"
        choose "yes"
        click_on "Continue"
        expect(find("strong.app-task-list__tag")).to have_text "Completed"
      end
    end
  end
end
