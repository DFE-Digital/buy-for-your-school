require "rails_helper"

feature "Anyone can start a journey" do
  before { user_is_signed_in }
  around do |example|
    ClimateControl.modify(
      CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID: "contentful-category-entry"
    ) do
      example.run
    end
  end

  scenario "Start page includes a call to action" do
    start_journey_from_category(category: "radio-question.json")

    expect(page).to have_content(I18n.t("specifying.start_page.page_title"))
    expect(page).to have_content("Radio task")
    expect(page).to have_content("Not started")
  end

  scenario "an answer must be provided" do
    start_journey_from_category_and_go_to_first_section(category: "radio-question.json")

    # Omit a choice

    click_on(I18n.t("generic.button.next"))

    expect(page).to have_content("can't be blank")
  end

  context "when the Contentful model is of type question" do
    context "when Contentful entry is of type short_text" do
      scenario "user can answer using free text" do
        start_journey_from_category_and_go_to_first_section(category: "short-text-question.json")

        fill_in "answer[response]", with: "email@example.com"
        click_on(I18n.t("generic.button.next"))

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("email@example.com")
      end
    end

    context "when Contentful entry is of type numbers" do
      scenario "user can answer using a number input" do
        start_journey_from_category_and_go_to_first_section(category: "number-question.json")

        fill_in "answer[response]", with: "190"
        click_on(I18n.t("generic.button.next"))

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("190")
      end

      scenario "users receive an error when not entering a number" do
        start_journey_from_category_and_go_to_first_section(category: "number-question.json")

        fill_in "answer[response]", with: "foo"
        click_on(I18n.t("generic.button.next"))

        expect(page).to have_content("is not a number")
      end

      scenario "users receive an error when entering a decimal number" do
        start_journey_from_category_and_go_to_first_section(category: "number-question.json")

        fill_in "answer[response]", with: "435.65"
        click_on(I18n.t("generic.button.next"))

        expect(page).to have_content("must be an integer")
      end
    end

    context "when Contentful entry is of type currency" do
      scenario "user can answer using a currency number input" do
        start_journey_from_category_and_go_to_first_section(category: "currency-question.json")

        fill_in "answer[response]", with: "1,000.01"
        click_on(I18n.t("generic.button.next"))

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("1000.01")
      end

      scenario "throws error when non numerical values are entered" do
        start_journey_from_category_and_go_to_first_section(category: "currency-question.json")

        fill_in "answer[response]", with: "one hundred pounds"
        click_on(I18n.t("generic.button.next"))

        expect(page).to have_content("does not accept £ signs or other non numerical characters")
      end
    end

    context "when Contentful entry is of type long_text" do
      scenario "user can answer using free text with multiple lines" do
        start_journey_from_category_and_go_to_first_section(category: "long-text-question.json")

        fill_in "answer[response]", with: "We would like a supplier to provide catering from September 2020.\nThey must be able to supply us for 3 years minumum."
        click_on(I18n.t("generic.button.next"))

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("We would like a supplier to provide catering from September 2020.\r\nThey must be able to supply us for 3 years minumum.")
      end
    end

    context "when Contentful entry is of type single_date" do
      scenario "user can answer using a date input" do
        start_journey_from_category_and_go_to_first_section(category: "single-date-question.json")

        fill_in "answer[response(3i)]", with: "12"
        fill_in "answer[response(2i)]", with: "8"
        fill_in "answer[response(1i)]", with: "2020"

        click_on(I18n.t("generic.button.next"))

        click_first_link_in_section_list

        expect(find_field("answer_response_3i").value).to eql("12")
        expect(find_field("answer_response_2i").value).to eql("8")
        expect(find_field("answer_response_1i").value).to eql("2020")
      end

      scenario "date validations" do
        start_journey_from_category_and_go_to_first_section(category: "single-date-question.json")

        fill_in "answer[response(3i)]", with: "2"
        fill_in "answer[response(2i)]", with: "0"
        fill_in "answer[response(1i)]", with: "0"

        click_on(I18n.t("generic.button.next"))
        expect(page).to have_content(I18n.t("activerecord.errors.models.single_date_answer.attributes.response"))
      end
    end

    context "when Contentful entry is of type checkboxes" do
      scenario "user can select multiple answers" do
        start_journey_from_category_and_go_to_first_section(category: "checkboxes-question.json")

        check "Breakfast"
        check "Lunch"

        click_on(I18n.t("generic.button.next"))

        click_first_link_in_section_list

        expect(page).to have_checked_field("answer-response-breakfast-field")
        expect(page).to have_checked_field("answer-response-lunch-field")
      end

      scenario "options follow the capitalisation given" do
        start_journey_from_category_and_go_to_first_section(category: "checkboxes-question.json")
        expect(page).to have_content("Morning break")
      end

      context "when extra configuration is passed to collect further info" do
        scenario "asks the user for further information" do
          start_journey_from_category_and_go_to_first_section(category: "extended-checkboxes-question.json")

          check("Yes")
          fill_in "answer[yes_further_information]", with: "The first piece of further information"

          check("No")
          expect(page).not_to have_content("No_further_information") # It should not create a label when text for one isn't provided
          within("span.govuk-visually-hidden") do
            expect(page).to have_content("Optional further information") # Default the hidden label to something understandable for screen readers
          end
          fill_in "answer[no_further_information]", with: "A second piece of further information"

          # We are testing a value that includes a comma
          check("Other, please specify")
          fill_in "answer[other_please_specify_further_information]", with: "Other information"

          click_on(I18n.t("generic.button.next"))

          click_first_link_in_section_list

          expect(page).to have_checked_field("Yes")
          expect(find_field("answer-yes-further-information-field").value)
            .to eql("The first piece of further information")

          expect(page).to have_checked_field("No")
          expect(find_field("answer-no-further-information-field").value)
            .to eql("A second piece of further information")

          expect(page).to have_checked_field("Other, please specify")
          expect(find_field("answer-other-please-specify-further-information-field").value)
            .to eql("Other information")
        end
      end

      context "when extended question is of type single" do
        scenario "a single text field is displayed" do
          start_journey_from_category_and_go_to_first_section(category: "extended-checkboxes-question.json")

          check("Yes")

          expect(page).to have_selector("input#answer-yes-further-information-field")
        end
      end

      context "when extended question is of type long" do
        scenario "a long text area is displayed" do
          start_journey_from_category_and_go_to_first_section(category: "extended-long-answer-checkboxes-question.json")

          check("Yes")

          expect(page).to have_selector("textarea#answer-yes-further-information-field")
        end
      end

      context "when there is no extended question" do
        scenario "no extra text field is displayed" do
          start_journey_from_category_and_go_to_first_section(category: "checkboxes-question.json")

          expect(page).to_not have_selector("textarea#answer-yes-further-information-field")
          expect(page).to_not have_selector("input#answer-yes-further-information-field")
        end
      end
    end

    context "when Contentful entry is of type radios" do
      context "when extra configuration is passed to collect further info" do
        scenario "asks the user for further information" do
          start_journey_from_category_and_go_to_first_section(category: "extended-radio-question.json")

          choose("Catering")
          expect(page).not_to have_content("No_further_information") # It should not create a label when one isn't specified
          within("span.govuk-visually-hidden") do
            expect(page).to have_content("Optional further information") # Default the hidden label to something understandable for screen readers
          end

          fill_in "answer[catering_further_information]", with: "The school needs the kitchen cleaned once a day"

          click_on(I18n.t("generic.button.next"))

          click_first_link_in_section_list

          expect(page).to have_checked_field("Catering")
          expect(find_field("answer-catering-further-information-field").value)
            .to eql("The school needs the kitchen cleaned once a day")
        end
      end

      context "when extended question is of type single" do
        scenario "a single text field is displayed" do
          start_journey_from_category_and_go_to_first_section(category: "extended-radio-question.json")

          choose("Catering")

          expect(page).to have_selector("input#answer-catering-further-information-field")
        end
      end

      context "when extended question is of type long" do
        scenario "a long text area is displayed" do
          start_journey_from_category_and_go_to_first_section(category: "extended-long-answer-radio-question.json")

          choose("Catering")

          expect(page).to have_selector("textarea#answer-catering-further-information-field")
        end
      end

      context "when there is no extended question" do
        scenario "no extra text field is displayed" do
          start_journey_from_category_and_go_to_first_section(category: "radio-question.json")

          expect(page).to_not have_selector("textarea#answer-catering-further-information-field")
          expect(page).to_not have_selector("input#answer-catering-further-information-field")
        end
      end

      context "when an 'or separator' has been configured" do
        scenario "shows an or separator" do
          start_journey_from_category_and_go_to_first_section(category: "radio-question-with-separator.json")

          expect(page).to have_selector("div.govuk-radios__divider")
          within("div.govuk-radios__divider") do
            expect(page).to have_content("or")
          end

          # Check that the "Or" separator appears in the correct position
          expect(page.body.index("Catering") > page.body.index("or")).to eq(true)
          expect(page.body.index("or") < page.body.index("Cleaning")).to eq(true)
        end
      end
    end

    context "when Contentful entry includes a 'show additional question' rule" do
      scenario "additional questions are shown" do
        start_journey_from_category_and_go_to_first_section(category: "show-one-additional-question.json")

        choose("School expert")
        click_on(I18n.t("generic.button.next"))

        # This question should be made visible after the previous step
        expect(page).not_to have_content("What colour is the sky?")
        click_on("Hidden field with additional question task")
        choose("Red")
        click_on(I18n.t("generic.button.next"))

        # This question should only be made visible after the previous step
        click_on("Hidden field task")
        choose("School expert")
        click_on(I18n.t("generic.button.next"))
      end
    end
  end

  context "when the question is skippable" do
    scenario "allows the user to not select an answer" do
      start_journey_from_category_and_go_to_first_section(category: "skippable-checkboxes-question.json")

      click_on(I18n.t("generic.button.next"))
      expect(page).to have_content("can't be blank")

      check("Lunch")
      check("Dinner")
      click_on(I18n.t("generic.button.next"))

      click_first_link_in_section_list

      click_on("None of the above")

      within(".app-task-list") do
        expect(page).to have_content("Complete")
      end

      click_first_link_in_section_list

      expect(page).not_to have_checked_field("Lunch")
      expect(CheckboxAnswers.last.skipped).to be true
    end

    context "when the question has already been skipped" do
      scenario "selecting an answer marks the question as not being skipped" do
        start_journey_from_category_and_go_to_first_section(category: "skippable-checkboxes-question.json")

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

  context "when the Contentful model is of type staticContent" do
    context "when Contentful entry is of type paragraphs" do
      scenario "the content is not displayed in the task list" do
        start_journey_from_category(category: "static-content.json")

        # We should really remove static content entirely, since it doesn't
        # appear in the task list pattern.

        # TODO: Talk to design and see if static content is actually included
        # anywhere in the journey, or if we can ditch support.

        expect(page).not_to have_content("When you should start")
      end
    end
  end

  context "when the help text contains Markdown" do
    scenario "paragraph breaks are parsed as expected" do
      start_journey_from_category_and_go_to_first_section(category: "markdown-help-text.json")

      expect(page.html).to include("<p>Paragraph Test: Paragraph 1</p>")
      expect(page.html).to include("<p>Paragraph Test: Paragraph 2</p>")
    end

    scenario "bold text is parsed as expected" do
      start_journey_from_category_and_go_to_first_section(category: "markdown-help-text.json")

      expect(page.html).to include("<strong>Bold text</strong> test")
    end

    scenario "lists are parsed as expected" do
      start_journey_from_category_and_go_to_first_section(category: "markdown-help-text.json")

      expect(page.html).to include("<li>List item one</li>")
      expect(page.html).to include("<li>List item two</li>")
      expect(page.html).to include("<li>List item three</li>")
    end
  end

  context "when the help text is nil" do
    scenario "step page still renders when question is a radio" do
      start_journey_from_category_and_go_to_first_section(category: "nil-help-text-radios.json")

      expect(page.html).to include("Which service do you need?")
    end

    scenario "step page still renders when question is a short text" do
      start_journey_from_category_and_go_to_first_section(category: "nil-help-text-short-text.json")

      expect(page.html).to include("What email address did you use?")
    end
  end

  context "when Contentful entry model wasn't an expected type" do
    scenario "returns an error message" do
      stub_contentful_category(fixture_filename: "unexpected-contentful-type.json")

      visit new_journey_path

      expect(page).to have_content(I18n.t("errors.unexpected_contentful_model.page_title"))
      expect(page).to have_content(I18n.t("errors.unexpected_contentful_model.page_body"))
    end
  end

  context "when the Contentful Entry wasn't an expected question type" do
    scenario "returns an error message" do
      stub_contentful_category(fixture_filename: "unexpected-contentful-question-type.json")

      visit new_journey_path

      expect(page).to have_content(I18n.t("errors.unexpected_contentful_step_type.page_title"))
      expect(page).to have_content(I18n.t("errors.unexpected_contentful_step_type.page_body"))
    end
  end

  context "when the starting entry id doesn't exist" do
    scenario "a Contentful entry_id does not exist" do
      allow(stub_contentful_connector).to receive(:get_entry_by_id)
        .with("contentful-category-entry")
        .and_return(nil)

      visit new_journey_path

      expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_title"))
      expect(page).to have_content(I18n.t("errors.contentful_entry_not_found.page_body"))
    end
  end

  context "when the Liquid template was invalid" do
    it "raises an error" do
      start_journey_from_category(category: "category-with-invalid-liquid-template.json")

      expect(page).to have_content(I18n.t("errors.specification_template_invalid.page_title"))
      expect(page).to have_content(I18n.t("errors.specification_template_invalid.page_body"))
    end
  end

  context "when a task has a single question and the user answers it" do
    scenario "the user is returned to the same place in the task list " do
      start_journey_from_category_and_go_to_first_section(category: "long-text-question.json")
      journey = Journey.last

      fill_in "answer[response]", with: "This is my long answer"

      click_on(I18n.t("generic.button.next"))

      answer = LongTextAnswer.last

      expect(page).to have_current_path(journey_url(journey, anchor: answer.step.id))
    end
  end

  context "when a task has more than 1 question" do
    scenario "the user is taken straight to the next question" do
      start_journey_from_category_and_go_to_first_section(category: "task-with-multiple-steps.json")
      journey = Journey.last
      task = journey.sections.first.tasks.first

      choose("Catering")
      click_on(I18n.t("generic.button.next"))

      fill_in "answer[response]", with: "This is my short answer"
      click_on(I18n.t("generic.button.next"))

      fill_in "answer[response]", with: "This is my long answer"
      click_on(I18n.t("generic.button.next"))

      check("Breakfast")
      click_on(I18n.t("generic.button.next"))

      expect(page).to have_content("Task with multiple steps")
      expect(page).to have_current_path(journey_task_url(journey, task))
    end
  end

  context "when a task that has no answers is opened" do
    scenario "takes the user straight to the first question" do
      start_journey_from_category(category: "task-with-multiple-steps.json")

      click_first_link_in_section_list

      expect(page).not_to have_content("Task with multiple steps")
      expect(page).to have_content("Catering")
    end
  end

  context "when a new journey is begun" do
    scenario "records that action in the event log" do
      start_journey_from_category(category: "radio-question.json")

      first_logged_event = ActivityLogItem.first
      expect(first_logged_event.action).to eq("begin_journey")
      expect(first_logged_event.journey_id).to eq(Journey.last.id)
      expect(first_logged_event.user_id).to eq(User.last.id)
      expect(first_logged_event.contentful_category_id).to eq(ENV["CONTENTFUL_DEFAULT_CATEGORY_ENTRY_ID"])
    end
  end

  context "when a user views a step which has not been answered" do
    scenario "an action is recorded" do
      start_journey_from_category_and_go_to_first_section(category: "radio-question.json")

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
      start_journey_with_tasks_from_category(category: "radio-question.json")

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

  context "when a user answers a question" do
    scenario "an action is recorded" do
      start_journey_from_category_and_go_to_first_section(category: "long-text-question.json")
      journey = Journey.last

      fill_in "answer[response]", with: "This is my long answer"

      click_on(I18n.t("generic.button.next"))

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
