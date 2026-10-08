require "rails_helper"

RSpec.describe "Register your interest in Energy for Schools" do
  it "shows an error when the name is missing" do
    post energy_register_your_interest_path, params: { energy_register_your_interest: { name: "" } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Enter your name")
  end

  it "shows an error when the contact phone number has fewer than 10 digits" do
    post energy_register_your_interest_path, params: { energy_register_your_interest: { name: "Alex Example" } }
    post energy_register_your_interest_email_path, params: { energy_register_your_interest: { email: "alex@example.com" } }
    post energy_register_your_interest_phone_number_path, params: { energy_register_your_interest: { phone_number: "1234 56789" } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Enter a telephone number, like 07155487611")
  end

  it "shows errors when check your answers is opened directly and continued with incomplete answers" do
    get energy_register_your_interest_path
    get energy_register_your_interest_check_your_answers_path

    expect(response).to be_successful
    expect(response.body).to include("There is a problem", "Enter your name")

    post energy_register_your_interest_check_your_answers_path

    expect(response).to redirect_to(energy_register_your_interest_check_your_answers_path)
    follow_redirect!
    expect(response).to be_successful
    expect(response.body).to include("There is a problem", "Enter your name")
  end

  it "rejects a gas contract end date more than five years in the future" do
    mat_type = create(:support_establishment_group_type, code: Support::EstablishmentGroupType::MAT_CODE, name: "Multi-academy trust")
    mat = create(:support_establishment_group, establishment_group_type: mat_type, uid: "MAT-123", name: "Example MAT", ukprn: "12345678")
    date = Date.current.advance(years: 6)

    post energy_register_your_interest_path, params: { energy_register_your_interest: { name: "Alex Example" } }
    post energy_register_your_interest_email_path, params: { energy_register_your_interest: { email: "alex@example.com" } }
    post energy_register_your_interest_phone_number_path, params: { energy_register_your_interest: { phone_number: "01234567890" } }
    post energy_register_your_interest_mat_path, params: { energy_register_your_interest: { mat_uid: mat.uid } }
    post energy_register_your_interest_gas_path, params: {
      energy_register_your_interest: {
        switch_gas: "true",
        "gas_contract_end_date(1i)" => date.year.to_s,
        "gas_contract_end_date(2i)" => date.month.to_s,
        "gas_contract_end_date(3i)" => date.day.to_s,
      },
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Enter a gas contract end date within the last 5 years and the next 5 years")
  end

  it "shows an error for an invalid electricity contract date component" do
    mat_type = create(:support_establishment_group_type, code: Support::EstablishmentGroupType::MAT_CODE, name: "Multi-academy trust")
    mat = create(:support_establishment_group, establishment_group_type: mat_type, uid: "MAT-123", name: "Example MAT", ukprn: "12345678")

    post energy_register_your_interest_path, params: { energy_register_your_interest: { name: "Alex Example" } }
    post energy_register_your_interest_email_path, params: { energy_register_your_interest: { email: "alex@example.com" } }
    post energy_register_your_interest_phone_number_path, params: { energy_register_your_interest: { phone_number: "01234567890" } }
    post energy_register_your_interest_mat_path, params: { energy_register_your_interest: { mat_uid: mat.uid } }
    post energy_register_your_interest_gas_path, params: { energy_register_your_interest: { switch_gas: "false" } }
    post energy_register_your_interest_electricity_path, params: {
      energy_register_your_interest: {
        switch_electricity: "true",
        "electricity_contract_end_date(1i)" => "2027",
        "electricity_contract_end_date(2i)" => "99",
        "electricity_contract_end_date(3i)" => "1",
      },
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Enter a valid electricity contract end date")
  end

  it "takes a user through the journey and persists their submitted answers" do
    mat_type = create(:support_establishment_group_type, code: Support::EstablishmentGroupType::MAT_CODE, name: "Multi-academy trust")
    mat = create(:support_establishment_group, establishment_group_type: mat_type, uid: "MAT-123", name: "Example MAT", ukprn: "12345678")

    post energy_register_your_interest_path, params: { energy_register_your_interest: { name: "Alex Example" } }
    expect(response).to redirect_to(energy_register_your_interest_email_path)
    follow_redirect!
    expect(response.body).to include("What is your email address?")

    post energy_register_your_interest_email_path, params: { energy_register_your_interest: { email: "alex@example.com" } }
    expect(response).to redirect_to(energy_register_your_interest_phone_number_path)
    follow_redirect!

    post energy_register_your_interest_phone_number_path, params: { energy_register_your_interest: { phone_number: "01234567890" } }
    expect(response).to redirect_to(energy_register_your_interest_mat_path)
    follow_redirect!

    post energy_register_your_interest_mat_path, params: { energy_register_your_interest: { mat_uid: mat.uid } }
    expect(response).to redirect_to(energy_register_your_interest_gas_path)
    follow_redirect!

    post energy_register_your_interest_gas_path, params: { energy_register_your_interest: { switch_gas: "true", "gas_contract_end_date(1i)" => "2027", "gas_contract_end_date(2i)" => "8", "gas_contract_end_date(3i)" => "1" } }
    expect(response).to redirect_to(energy_register_your_interest_electricity_path)
    follow_redirect!

    post energy_register_your_interest_electricity_path, params: { energy_register_your_interest: { switch_electricity: "false" } }
    expect(response).to redirect_to(energy_register_your_interest_check_your_answers_path)
    follow_redirect!
    expect(response.body).to include("Alex Example", "alex@example.com", "Example MAT", "Yes", "No")

    registration = Energy::RegisterYourInterest.find(session[:energy_register_your_interest_id])
    expect(registration).to have_attributes(
      name: "Alex Example",
      email: "alex@example.com",
      phone_number: "01234567890",
      mat_uid: mat.uid,
      mat_name: mat.name,
      ukprn: mat.ukprn,
      switch_gas: true,
      gas_contract_end_date: Date.new(2027, 8, 1),
      switch_electricity: false,
      status: "in_progress",
    )

    post energy_register_your_interest_check_your_answers_path
    expect(response).to redirect_to(energy_register_your_interest_confirmation_path)
    expect(registration.reload).to be_submitted

    follow_redirect!
    expect(response).to be_successful
    expect(response.body).to include("confirmation email")
  end
end
