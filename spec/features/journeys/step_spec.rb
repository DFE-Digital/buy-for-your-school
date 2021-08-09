RSpec.feature "Steps" do
  let(:user) { create(:user) }
  let(:fixture) { "task-with-multiple-steps.json" }

  before do
    user_is_signed_in(user: user)
    # TODO: setup with factory
    start_journey_from_category(category: fixture)
  end

  describe "step types" do
    # TODO: refactor these into shared examples - 'it behaves like XXX'
    context "when the step is of type short_text" do
      let(:fixture) { "short-text-question.json" }

      scenario "user can answer using free text" do
        click_first_link_in_section_list

        fill_in "answer[response]", with: "email@example.com"
        click_continue

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("email@example.com")
      end
    end

    context "when the step is of type long_text" do
      let(:fixture) { "long-text-question.json" }

      scenario "user can answer using free text with multiple lines" do
        click_first_link_in_section_list

        fill_in "answer[response]", with: "We would like a supplier to provide catering from September 2020.\nThey must be able to supply us for 3 years minumum."
        click_continue

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("We would like a supplier to provide catering from September 2020.\r\nThey must be able to supply us for 3 years minumum.")
      end
    end

    context "when the step is of type markdown" do
      let(:fixture) { "statement.json" }

      scenario "the statement is not displayed in the task list" do
        expect(page).not_to have_content("statement-step.json title")
      end

      scenario "the statement can be acknowledged" do
        journey = Journey.last
        task = Task.find_by(title: "Task with a single statement step")
        step = task.steps.first

        visit journey_step_path(journey, step)

        expect(find("h1.govuk-heading-xl")).to have_text "statement-step.json title"
        within("div.govuk-body") do
          expect(page.html).to include("<h4>Heading 4</h4>")
        end
        expect(page).to have_button("Acknowledge!")
        click_on("Acknowledge!")
        expect(Task.find(task.id).statement_ids).to include(step.id)
      end
    end

    context "when the step is of type number" do
      let(:fixture) { "number-question.json" }

      scenario "user can answer using a number input" do
        click_first_link_in_section_list

        fill_in "answer[response]", with: "190"
        click_continue

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("190")
      end

      scenario "users receive an error when not entering a number" do
        click_first_link_in_section_list

        fill_in "answer[response]", with: "foo"
        click_continue

        expect(page).to have_content("is not a number")
      end

      scenario "users receive an error when entering a decimal number" do
        click_first_link_in_section_list

        fill_in "answer[response]", with: "435.65"
        click_continue

        expect(page).to have_content("must be an integer")
      end
    end

    context "when the step is of type currency" do
      let(:fixture) { "currency-question.json" }

      scenario "user can answer using a currency number input" do
        click_first_link_in_section_list

        fill_in "answer[response]", with: "1,000.01"
        click_continue

        click_first_link_in_section_list

        expect(find_field("answer-response-field").value).to eql("1000.01")
      end

      scenario "throws error when non numerical values are entered" do
        click_first_link_in_section_list

        fill_in "answer[response]", with: "one hundred pounds"
        click_continue

        expect(page).to have_content("does not accept £ signs or other non numerical characters")
      end
    end

    context "when the step is of type single date" do
      let(:fixture) { "single-date-question.json" }

      scenario "user can answer using a date input" do
        click_first_link_in_section_list

        fill_in "answer[response(3i)]", with: "12"
        fill_in "answer[response(2i)]", with: "8"
        fill_in "answer[response(1i)]", with: "2020"

        click_continue

        click_first_link_in_section_list

        expect(find_field("answer_response_3i").value).to eql("12")
        expect(find_field("answer_response_2i").value).to eql("8")
        expect(find_field("answer_response_1i").value).to eql("2020")
      end

      scenario "date validations" do
        click_first_link_in_section_list

        fill_in "answer[response(3i)]", with: "2"
        fill_in "answer[response(2i)]", with: "0"
        fill_in "answer[response(1i)]", with: "0"

        click_continue
        expect(page).to have_content("Provide a real date for this answer")
      end
    end

    context "when the step is of type checkboxes" do
      let(:fixture) { "checkboxes-question.json" }

      scenario "user can select multiple answers" do
        click_first_link_in_section_list

        check "Breakfast"
        check "Lunch"

        click_continue

        click_first_link_in_section_list

        expect(page).to have_current_path %r{/journeys/.*/steps/.*/edit}
        expect(page).to have_checked_field("answer-response-breakfast-field")
        expect(page).to have_checked_field("answer-response-lunch-field")
      end

      scenario "options follow the capitalisation given" do
        click_first_link_in_section_list

        expect(page).to have_current_path %r{/journeys/.*/steps/.*}
        expect(find("div.govuk-checkboxes")).to have_text "Morning break"
      end

      context "with extended checkboxes" do
        let(:fixture) { "extended-checkboxes-question.json" }

        context "when extra configuration is passed to collect further info" do
          scenario "asks the user for further information" do
            click_first_link_in_section_list

            check "Yes"
            fill_in "answer[yes_further_information]", with: "The first piece of further information"

            check "No"
            expect(page).not_to have_content("No_further_information") # It should not create a label when text for one isn't provided
            within("span.govuk-visually-hidden") do
              expect(page).to have_content("Optional further information") # Default the hidden label to something understandable for screen readers
            end
            fill_in "answer[no_further_information]", with: "A second piece of further information"

            # We are testing a value that includes a comma
            check "Other, please specify"
            fill_in "answer[other_please_specify_further_information]", with: "Other information"

            click_continue

            click_first_link_in_section_list

            expect(page).to have_current_path %r{/journeys/.*/steps/.*/edit}

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
            click_first_link_in_section_list
            check "Yes"
            expect(page).to have_current_path %r{/journeys/.*/steps/.*}
            expect(page).to have_selector("input#answer-yes-further-information-field")
          end
        end
      end

      context "when extended question is of type long" do
        # TODO: setup with factory
        let(:fixture) { "extended-long-answer-checkboxes-question.json" }

        scenario "a long text area is displayed" do
          click_first_link_in_section_list
          check "Yes"
          expect(page).to have_current_path %r{/journeys/.*/steps/.*}
          expect(page).to have_selector("textarea#answer-yes-further-information-field")
        end
      end

      context "when there is no extended question" do
        scenario "no extra text field is displayed" do
          click_first_link_in_section_list

          expect(page).to have_current_path %r{/journeys/.*/steps/.*}
          expect(page).not_to have_selector("textarea#answer-yes-further-information-field")
          expect(page).not_to have_selector("input#answer-yes-further-information-field")
        end
      end
    end

    context "when the step is of type radios" do
      let(:fixture) { "extended-radio-question.json" }

      context "when extra configuration is passed to collect further info" do
        scenario "asks the user for further information" do
          click_first_link_in_section_list

          choose "Catering"
          expect(page).not_to have_content("No_further_information") # It should not create a label when one isn't specified
          within("span.govuk-visually-hidden") do
            expect(page).to have_content("Optional further information") # Default the hidden label to something understandable for screen readers
          end

          fill_in "answer[catering_further_information]", with: "The school needs the kitchen cleaned once a day"

          click_continue

          click_first_link_in_section_list

          expect(page).to have_checked_field("Catering")
          expect(find_field("answer-catering-further-information-field").value)
            .to eql("The school needs the kitchen cleaned once a day")
        end
      end

      context "when extended question is of type single" do
        scenario "a single text field is displayed" do
          click_first_link_in_section_list
          choose "Catering"
          expect(page).to have_selector("input#answer-catering-further-information-field")
        end
      end

      context "when extended question is of type long" do
        let(:fixture) { "extended-long-answer-radio-question.json" }

        scenario "a long text area is displayed" do
          click_first_link_in_section_list
          choose "Catering"
          expect(page).to have_selector("textarea#answer-catering-further-information-field")
        end
      end

      context "when there is no extended question" do
        let(:fixture) { "radio-question.json" }

        scenario "no extra text field is displayed" do
          click_first_link_in_section_list

          expect(page).not_to have_selector("textarea#answer-catering-further-information-field")
          expect(page).not_to have_selector("input#answer-catering-further-information-field")
        end
      end

      context "when an 'or separator' has been configured" do
        let(:fixture) { "radio-question-with-separator.json" }

        scenario "shows an or separator" do
          click_first_link_in_section_list

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
  end

  describe "rules" do
    context "with additional question rule" do
      let(:fixture) { "show-one-additional-question.json" }

      scenario "additional questions are shown" do
        click_first_link_in_section_list

        choose "School expert"
        click_continue

        # This question should be made visible after the previous step
        expect(page).not_to have_content("What colour is the sky?")
        click_on("Hidden field with additional question task")
        choose("Red")
        click_continue

        # This question should only be made visible after the previous step
        click_on("Hidden field task")
        choose("School expert")
        click_continue
      end
    end

    context "with skippable rule" do
      let(:fixture) { "skippable-checkboxes-question.json" }

      scenario "allows the user to not select an answer" do
        click_first_link_in_section_list

        click_continue
        expect(find("span.govuk-error-message")).to have_text "can't be blank"

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

      context "when the question has already been skipped" do
        scenario "selecting an answer marks the question as not being skipped" do
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
  end

  describe "exceptions" do
    context "when Contentful entry model wasn't an expected type" do
      let(:fixture) { "unexpected-contentful-type.json" }

      scenario "returns an error message" do
        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
        expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
      end
    end

    context "when the Contentful Entry wasn't an expected question type" do
      let(:fixture) { "unexpected-contentful-question-type.json" }

      scenario "returns an error message" do
        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
        expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
      end
    end

    context "when the starting entry id doesn't exist" do
      scenario "a Contentful entry_id does not exist" do
        allow(stub_client).to receive(:by_id).with("contentful-category-entry").and_return(nil)

        category = create(:category, contentful_id: "contentful-category-entry")

        user_signs_in_and_starts_the_journey(category.id)

        expect(find("h1.govuk-heading-xl")).to have_text "An unexpected error occurred"
        expect(find("p.govuk-body")).to have_text "The service has had a problem trying to retrieve the required step. The team have been notified of this problem and you should be able to retry shortly."
      end
    end
  end

  describe "activity logging" do
    # TODO: could this be joined with log download spec into an log_activity_spec?
    let(:fixture) { "radio-question.json" }

    context "when a new journey is begun" do
      scenario "records that action in the event log" do
        first_logged_event = ActivityLogItem.first
        expect(first_logged_event.action).to eq("begin_journey")
        expect(first_logged_event.journey_id).to eq(Journey.last.id)
        expect(first_logged_event.user_id).to eq(User.last.id)
        expect(first_logged_event.contentful_category_id).to eq("contentful-category-entry")
      end
    end

    context "when a user views a step which has not been answered" do
      scenario "an action is recorded" do
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
      let(:fixture) { "long-text-question.json" }

      scenario "an action is recorded" do
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
end
