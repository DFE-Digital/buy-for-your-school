RSpec.feature "User answers are rendered correctly based on type" do
  let(:user) { create(:user) }

  before do
    user_is_signed_in(user: user)
    # TODO: replace fixture with factory
    start_journey_from_category(category: "section-with-multiple-tasks.json")
    within ".app-task-list" do
      click_on "Task containing every type of step"
    end
    click_on "Back"
  end

  specify do
    expect(page).to have_a_task_path
  end

  specify do
    expect(page).not_to have_a_step_path
  end

  # RadioAnswerPresenter#response
  specify do
    click_link "radios"
    expect(page).to have_a_step_path
    choose "Cleaning"
    click_on "Continue"
    expect(page).to have_a_step_path
    click_on "Back"
    expect(page).to have_a_task_path
    within("div.govuk-summary-list__row", text: "Which service do you need?") do
      expect(find("dd.govuk-summary-list__value")).to have_text "Cleaning"
    end
  end

  # ShortTextAnswerPresenter#response
  specify do
    click_link "short_text"
    expect(page).to have_a_step_path
    fill_in "answer[response]", with: "hello_world@example.com"
    click_on "Continue"
    expect(page).to have_a_step_path
    click_on "Back"
    expect(page).to have_a_task_path
    within("div.govuk-summary-list__row", text: "What email address did you use?") do
      expect(find("dd.govuk-summary-list__value")).to have_text "hello_world@example.com"
    end
  end

  # LongTextAnswerPresenter#response
  specify do
    click_link "long_text"
    expect(page).to have_a_step_path
    fill_in "answer[response]", with: "\r\n\r\nfoo\r\n\r\n"
    click_on "Continue"
    expect(page).to have_a_step_path
    click_on "Back"
    expect(page).to have_a_task_path
    within("div.govuk-summary-list__row", text: "Describe what you need") do
      expect(find("dd.govuk-summary-list__value")).to have_text "foo"
    end
  end

  # CurrencyAnswerPresenter#response
  specify do
    click_link "currency"
    expect(page).to have_a_step_path
    fill_in "answer[response]", with: "2,999.99001"
    click_on "Continue"
    expect(page).to have_a_step_path
    click_on "Back"
    expect(page).to have_a_task_path
    within("div.govuk-summary-list__row", text: "What funds does the school have available for the maintenance or replacement of heavy equipment in the coming year?") do
      expect(find("dd.govuk-summary-list__value")).to have_text "£2,999.99"
    end
  end

  # NumberAnswerPresenter#response
  specify do
    click_link "number"
    expect(page).to have_a_step_path
    fill_in "answer[response]", with: "123"
    click_on "Continue"
    expect(page).to have_a_step_path
    click_on "Back"
    expect(page).to have_a_task_path
    within("div.govuk-summary-list__row", text: "How many days of the year will the service operate?") do
      expect(find("dd.govuk-summary-list__value")).to have_text "123"
    end
  end

  # SingleDateAnswerPresenter#response
  specify do
    click_link "single_date"
    expect(page).to have_a_step_path
    fill_in "answer[response(3i)]", with: "1"
    fill_in "answer[response(2i)]", with: "6"
    fill_in "answer[response(1i)]", with: "2021"
    click_on "Continue"
    expect(page).to have_a_task_path
    within("div.govuk-summary-list__row", text: "When will this start?") do
      expect(find("dd.govuk-summary-list__value")).to have_text "1 Jun 2021"
    end
  end

  # CheckboxesAnswerPresenter#concatenated_response
  specify do
    click_link "checkboxes"
    expect(page).to have_a_step_path
    check "Lunch"
    check "Dinner"
    click_on "Continue"
    expect(page).to have_a_step_path
    click_on "Back"
    expect(page).to have_a_task_path
    within("div.govuk-summary-list__row", text: "Everyday services that are required and need to be considered") do
      expect(find("dd.govuk-summary-list__value")).to have_text "Lunch, Dinner"
      expect(find("dd.govuk-summary-list__value")).not_to have_text '["Lunch", "Dinner"]'
    end
  end
end
