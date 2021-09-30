# TODO: Use new custom path matchers after each page change (example given below)
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
    expect(page).to have_content "Cleaning"
  end

  # ShortTextAnswerPresenter#response
  specify do
    click_link "short_text"
    fill_in "answer[response]", with: "hello_world@example.com"
    click_on "Continue"
    click_on "Back"
    expect(page).to have_content "hello_world@example.com"
  end

  # LongTextAnswerPresenter#response
  specify do
    click_link "long_text"
    fill_in "answer[response]", with: "\r\n\r\nfoo\r\n\r\n"
    click_on "Continue"
    click_on "Back"
    expect(page).to have_text "\r\r \r\r foo\r\r \r\r"
  end

  # CurrencyAnswerPresenter#response
  specify do
    click_link "currency"
    fill_in "answer[response]", with: "2,999.99001"
    click_on "Continue"
    click_on "Back"
    expect(page).to have_content "£2,999.99"
  end

  # NumberAnswerPresenter#response
  specify do
    click_link "number"
    fill_in "answer[response]", with: "123"
    click_on "Continue"
    click_on "Back"
    expect(page).to have_content "123"
  end

  # SingleDateAnswerPresenter#response
  specify do
    click_link "single_date"
    fill_in "answer[response(3i)]", with: "1"
    fill_in "answer[response(2i)]", with: "6"
    fill_in "answer[response(1i)]", with: "2021"
    click_on "Continue"
    expect(page).to have_content "1 Jun 2021"
  end

  # CheckboxesAnswerPresenter#concatenated_response
  specify do
    click_link "checkboxes"
    check "Lunch"
    check "Dinner"
    click_on "Continue"
    click_on "Back"
    expect(page).not_to have_content '["Lunch", "Dinner"]'
    expect(page).to have_content "Lunch, Dinner"
  end
end
