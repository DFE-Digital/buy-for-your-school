RSpec.feature "Users can view the task list" do # journeys#show
  let(:user) { create(:user) }
  let(:fixture) { "multiple-sections.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: replace fixture with factory
    start_journey_from_category(category: fixture)
  end

  it { expect(page).to have_a_journey_path }

  it "offers support with requests" do
    expect(page).to have_link "Request free help and support with your specification", href: "/profile" # , class: "govuk-link"
  end

  it "tasks are grouped by their section" do
    within(".app-task-list") do
      section_headings = find_all("h2.app-task-list__section")
      expect(section_headings[0]).to have_text "Section A" # > radio-section.json
      expect(section_headings[1]).to have_text "Section B" # > long-text-section.json
    end

    task_lists = find_all(".app-task-list__items")

    within(task_lists[0]) do
      expect(page).to have_content "Radio task" # > radio-task.json
    end

    within(task_lists[1]) do
      expect(page).to have_content "Long text task" # > long-text-task.json
    end
  end

  it "user can navigate back to the dashboard from a journey" do
    click_breadcrumb "Dashboard"
    expect(page).to have_content "Specifications dashboard" # dashboard.header
  end

  context "when a task has one step" do
    let(:fixture) { "section-with-single-task.json" }

    it "user can navigate back to the task list from a step" do
      within(".app-task-list") do
        click_on "Task with a single step" # > checkboxes_task.json
      end

      click_back
      expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure catering for your school"
    end
  end

  context "when a task has multiple steps" do
    let(:fixture) { "section-with-multiple-tasks.json" }

    it "shows the section title" do
      within(".app-task-list") do
        expect(page).to have_content "Section with multiple tasks" # > multiple_tasks_section.json
      end
    end

    it "shows the task titles within the section" do
      within(".app-task-list") do
        expect(page).to have_content "Task with multiple steps" # > checkboxes_and_radio_task.json
      end
    end

    it "the Task title takes you to the first step" do
      within(".app-task-list") do
        click_on "Task with multiple steps" # > checkboxes_and_radio_task.json
      end

      expect(page).to have_content "Which service do you need?"
    end

    it "user can navigate back to the task list from a list of questions" do
      # straight to first step
      within ".app-task-list" do
        click_on "Task with multiple steps" # > checkboxes_and_radio_task.json
      end

      # list of steps
      click_back
      expect(page).to have_content "Return to task list" # task.button.back

      # list of tasks
      click_on "Return to task list" # task.button.back
      expect(page).to have_content "Create a specification to procure catering for your school"
    end

    it "shows a list of the task steps" do
      within(".app-task-list") do
        click_on "Task with multiple steps" # > checkboxes_and_radio_task.json
      end

      # Unstarted tasks take the user straight to the first step so we have to go back
      click_back

      expect(page).to have_content "Which service do you need?"
      expect(page).to have_content "Everyday services that are required and need to be considered" # TODO: #675 refactor multiple
    end

    it "allows the user to click on a step to supply an answer, and be taken to the next step" do
      within(".app-task-list") do
        click_on "Task with multiple steps" # > checkboxes_and_radio_task.json
      end

      choose "Catering"
      click_continue

      expect(page).to have_content "What email address did you use?"
    end

    it "allows the user to click on a step to supply the last answer in a task, and be taken to the check your answers page" do
      within(".app-task-list") do
        click_on "Task with multiple steps" # > checkboxes_and_radio_task.json
      end

      choose "Catering"
      click_continue

      fill_in "answer[response]", with: "This is my short answer"
      click_continue

      fill_in "answer[response]", with: "This is my long answer"
      click_continue

      check "Breakfast"
      click_continue

      expect(page).to have_content "Task with multiple steps"
      within(".govuk-summary-list") do
        expect(page).to have_content "Catering"
      end
    end

    context "when a task has at least one answered step" do
      it "takes the user to the task page" do
        task = Task.find_by(title: "Task with multiple steps")
        step = task.steps.first
        create(:radio_answer, step: step)

        within(".app-task-list") do
          click_on "Task with multiple steps" # > checkboxes_and_radio_task.json
        end

        expect(page).to have_content "Task with multiple steps"
        expect(page).to have_content "Which service do you need?"
      end
    end
  end
end
