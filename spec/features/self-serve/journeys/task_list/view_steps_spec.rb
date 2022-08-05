RSpec.feature "Users can view the task list" do # journeys#show
  let(:user) { create(:user) }
  let(:category) { create(:category, :catering) }
  let(:journey) { create(:journey, user:, category:) }
  let(:section_a) { create(:section, title: "Section A", journey:) }
  let(:section_b) { create(:section, title: "Section B", journey:) }

  before do
    task_radio = create(:task, title: "Radio task", section: section_a)
    create(:task, :with_steps, title: "Long text task", section: section_b)
    create(:step, :radio, title: "Which service do you need?", options: [{ "value" => "Catering" }], task: task_radio, order: 0)
    create(:step, :short_text, title: "What email address did you use?", task: task_radio, order: 1)
    create(:step, :long_text, title: "Describe what you need", task: task_radio, order: 2)
    create(:step, :checkbox, title: "Everyday services that are required and need to be considered", options: [{ "value" => "Breakfast" }], task: task_radio, order: 3)
    user_is_signed_in(user:)
    visit "/journeys/#{journey.id}"
  end

  it { expect(page).to have_a_journey_path }

  it "offers support with requests" do
    expect(page).to have_link "Request free help and support with your specification", href: "/support-requests", class: "govuk-link"
  end

  it "tasks are grouped by their section" do
    within(".app-task-list") do
      section_headings = find_all("h2.app-task-list__section")
      expect(section_headings[0]).to have_text "Section A"
      expect(section_headings[1]).to have_text "Section B"
    end

    task_lists = find_all(".app-task-list__items")

    within(task_lists[0]) do
      expect(page).to have_content "Radio task"
    end

    within(task_lists[1]) do
      expect(page).to have_content "Long text task"
    end
  end

  it "user can navigate back to the dashboard from a journey" do
    click_breadcrumb "Dashboard"
    expect(page).to have_content "Specifications dashboard" # dashboard.header
  end

  context "when a task has one step" do
    it "user can navigate back to the task list from a step" do
      within(".app-task-list") do
        click_on "Long text task"
      end

      click_back
      expect(find("h1.govuk-heading-xl")).to have_text "Create your specification to procure catering for your school"
    end
  end

  context "when a task has multiple steps" do
    it "shows the section title" do
      within(".app-task-list") do
        expect(page).to have_content "Section A"
      end
    end

    it "shows the task titles within the section" do
      within(".app-task-list") do
        expect(page).to have_content "Radio task"
      end
    end

    it "the Task title takes you to the first step" do
      within(".app-task-list") do
        click_on "Radio task"
      end

      expect(page).to have_content "Which service do you need?"
    end

    it "user can navigate back to the task list from a list of questions" do
      # straight to first step
      within ".app-task-list" do
        click_on "Radio task"
      end

      # list of steps
      click_back
      expect(page).to have_content "Return to task list" # task.button.back

      # list of tasks
      click_on "Return to task list" # task.button.back
      expect(page).to have_content "Create your specification to procure catering for your school"
    end

    it "shows a list of the task steps" do
      within(".app-task-list") do
        click_on "Radio task"
      end

      # Unstarted tasks take the user straight to the first step so we have to go back
      click_back

      expect(page).to have_content "Which service do you need?"
      expect(page).to have_content "Everyday services that are required and need to be considered" # TODO: #675 refactor multiple
    end

    it "allows the user to click on a step to supply an answer, and be taken to the next step" do
      within(".app-task-list") do
        click_on "Radio task"
      end

      choose "Catering"
      click_continue

      expect(page).to have_content "What email address did you use?"
    end

    it "allows the user to click on a step to supply the last answer in a task, and be taken to the check your answers page" do
      within(".app-task-list") do
        click_on "Radio task"
      end

      choose "Catering"
      click_continue

      fill_in "answer[response]", with: "This is my short answer"
      click_continue

      fill_in "answer[response]", with: "This is my long answer"
      click_continue

      check "Breakfast"
      click_continue

      expect(page).to have_content "Radio task"
      within(".govuk-summary-list") do
        expect(page).to have_content "Catering"
      end
    end

    context "when a task has at least one answered step" do
      it "takes the user to the task page" do
        task = Task.find_by(title: "Radio task")
        step = task.steps.first
        create(:radio_answer, step:)

        within(".app-task-list") do
          click_on "Radio task"
        end

        expect(page).to have_content "Radio task"
        expect(page).to have_content "Which service do you need?"
      end
    end
  end
end
