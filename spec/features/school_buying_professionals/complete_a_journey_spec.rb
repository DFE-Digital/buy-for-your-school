# TODO: 600+ lines is too long for a single spec file
#
RSpec.feature "Anyone can start a journey" do
  before { user_is_signed_in }

  scenario "Start page includes a call to action" do
    # TODO: replace fixture with factory
    start_journey_from_category(category: "radio-question_types.json")

    expect(find("h1.govuk-heading-xl")).to have_text "Create a specification to procure catering for your school"
    expect(page).to have_content("Radio task")
    expect(page).to have_content("Not started")
  end

  context "when a new journey is begun" do
    scenario "records that action in the event log" do
      start_journey_from_category(category: "radio-question_types.json")

      first_logged_event = ActivityLogItem.first
      expect(first_logged_event.action).to eq("begin_journey")
      expect(first_logged_event.journey_id).to eq(Journey.last.id)
      expect(first_logged_event.user_id).to eq(User.last.id)
      expect(first_logged_event.contentful_category_id).to eq("contentful-category-entry")
    end
  end

  scenario "an answer must be provided" do
    start_journey_from_category(category: "radio-question_types.json")
    click_first_link_in_section_list

    # Omit a choice
    click_continue
    expect(page).to have_content "can't be blank"
  end

  context "when the question_types is skippable" do
    scenario "allows the user to not select an answer" do
      start_journey_from_category(category: "skippable-checkboxes-question_types.json")
      click_first_link_in_section_list

      click_continue
      expect(page).to have_content("can't be blank")

      check("Lunch")
      check("Dinner")
      click_continue

      click_first_link_in_section_list

      click_on("None of the above")

      within(".app-task-list") do
        expect(page).to have_content("Complete")
      end

      click_first_link_in_section_list

      expect(page).not_to have_checked_field("Lunch")
      expect(CheckboxAnswers.last.skipped).to be true
    end

    context "when the question_types has already been skipped" do
      scenario "selecting an answer marks the question_types as not being skipped" do
        start_journey_from_category(category: "skippable-checkboxes-question_types.json")
        click_first_link_in_section_list

        click_on("None of the above")

        within(".app-task-list") do
          expect(page).to have_content("Complete")
        end

        click_first_link_in_section_list

        check("Lunch")
        check("Dinner")
        click_on(I18n.t("generic.button.update"))

        expect(CheckboxAnswers.last.skipped).to be false
      end
    end
  end


  context "when the help text contains Markdown" do
    scenario "paragraph breaks are parsed as expected" do
      start_journey_from_category(category: "markdown-help-text.json")
      click_first_link_in_section_list

      expect(page.html).to include("<p>Paragraph Test: Paragraph 1</p>")
      expect(page.html).to include("<p>Paragraph Test: Paragraph 2</p>")
    end

    scenario "bold text is parsed as expected" do
      start_journey_from_category(category: "markdown-help-text.json")
      click_first_link_in_section_list

      expect(page.html).to include("<strong>Bold text</strong> test")
    end

    scenario "lists are parsed as expected" do
      start_journey_from_category(category: "markdown-help-text.json")
      click_first_link_in_section_list

      expect(page.html).to include("<li>List item one</li>")
      expect(page.html).to include("<li>List item two</li>")
      expect(page.html).to include("<li>List item three</li>")
    end
  end

  context "when the help text is nil" do
    scenario "step page still renders when question_types is a radio" do
      start_journey_from_category(category: "nil-help-text-radios.json")
      click_first_link_in_section_list

      expect(page.html).to include("Which service do you need?")
    end

    scenario "step page still renders when question_types is a short text" do
      start_journey_from_category(category: "nil-help-text-short-text.json")
      click_first_link_in_section_list

      expect(page.html).to include("What email address did you use?")
    end
  end



  context "when a task has a single question_types and the user answers it" do
    scenario "the user is returned to the same place in the task list " do
      start_journey_from_category(category: "long-text-question_types.json")
      click_first_link_in_section_list

      journey = Journey.last

      fill_in "answer[response]", with: "This is my long answer"

      click_continue

      answer = LongTextAnswer.last

      expect(page).to have_current_path(journey_url(journey, anchor: answer.step.id))
    end
  end

  context "when a task has more than 1 question_types" do
    scenario "the user is taken straight to the next question_types" do
      start_journey_from_category(category: "task-with-multiple-steps.json")
      click_first_link_in_section_list

      journey = Journey.last
      task = journey.sections.first.tasks.first

      choose "Catering"
      click_continue

      fill_in "answer[response]", with: "This is my short answer"
      click_continue

      fill_in "answer[response]", with: "This is my long answer"
      click_continue

      check("Breakfast")
      click_continue

      expect(page).to have_content("Task with multiple steps")
      expect(page).to have_current_path(journey_task_url(journey, task))
    end
  end

  context "when a task that has no answers is opened" do
    scenario "takes the user straight to the first question_types" do
      start_journey_from_category(category: "task-with-multiple-steps.json")

      click_first_link_in_section_list

      expect(page).not_to have_content("Task with multiple steps")
      expect(page).to have_content("Catering")
    end
  end



  context "when a user views a step which has not been answered" do
    scenario "an action is recorded" do
      start_journey_from_category(category: "radio-question_types.json")
      click_first_link_in_section_list

      step = Step.last

      last_logged_event = ActivityLogItem.last
      expect(last_logged_event.action).to eq("begin_step")
      expect(last_logged_event.journey_id).to eq(Journey.last.id)
      expect(last_logged_event.user_id).to eq(User.last.id)
      expect(last_logged_event.contentful_category_id).to eq("contentful-category-entry")
      expect(last_logged_event.contentful_section_id).to eq(step.task.section.contentful_id)
      expect(last_logged_event.contentful_task_id).to eq(step.task.contentful_id)
      expect(last_logged_event.contentful_step_id).to eq(step.contentful_id)
    end
  end

  context "when a user views a previously answered step" do
    scenario "an action is recorded" do
      start_journey_from_category(category: "radio-question_types.json")

      journey = Journey.last
      task = Task.find_by(title: "Radio task")
      step = task.steps.first
      create(:radio_answer, step: step)

      visit edit_journey_step_path(journey, step)

      last_logged_event = ActivityLogItem.last
      expect(last_logged_event.action).to eq("view_step")
      expect(last_logged_event.journey_id).to eq(journey.id)
      expect(last_logged_event.user_id).to eq(User.last.id)
      expect(last_logged_event.contentful_category_id).to eq("contentful-category-entry")
      expect(last_logged_event.contentful_section_id).to eq(step.task.section.contentful_id)
      expect(last_logged_event.contentful_task_id).to eq(step.task.contentful_id)
      expect(last_logged_event.contentful_step_id).to eq(step.contentful_id)
    end
  end

  context "when a user answers a question_types" do
    scenario "an action is recorded" do
      start_journey_from_category(category: "long-text-question_types.json")
      click_first_link_in_section_list

      journey = Journey.last

      fill_in "answer[response]", with: "This is my long answer"

      click_continue

      save_answer_logged_event = ActivityLogItem.where(action: "save_answer").first
      expect(save_answer_logged_event.journey_id).to eq(journey.id)
      expect(save_answer_logged_event.user_id).to eq(User.last.id)
      expect(save_answer_logged_event.contentful_category_id).to eq("contentful-category-entry")
      expect(save_answer_logged_event.contentful_section_id).to eq(Section.last.contentful_id)
      expect(save_answer_logged_event.contentful_task_id).to eq(Task.last.contentful_id)
      expect(save_answer_logged_event.contentful_step_id).to eq(Step.last.contentful_id)
      expect(save_answer_logged_event.data["success"]).to eq true
    end
  end
end
