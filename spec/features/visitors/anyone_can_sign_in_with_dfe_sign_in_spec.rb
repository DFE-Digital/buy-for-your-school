require "rails_helper"

feature "Anyone can sign in with DfE Sign-in" do
  scenario "signs in successfully" do
    stub_contentful_category(fixture_filename: "radio-question.json")
    user_exists_in_dfe_sign_in

    user_signs_in_using_dfe_sign_in

    expect(page).to have_content(I18n.t("specifying.start_page.page_title"))
  end

  scenario "sign in fails" do
    user_sign_in_attempt_fails

    expect(Rollbar).to receive(:error)
      .with("Sign in failed unexpectedly")
      .and_call_original

    user_signs_in_using_dfe_sign_in

    expect(page).to have_content(I18n.t("errors.sign_in.unexpected_failure.page_title"))
    expect(page).to have_content(I18n.t("errors.sign_in.unexpected_failure.page_body"))
  end
end
