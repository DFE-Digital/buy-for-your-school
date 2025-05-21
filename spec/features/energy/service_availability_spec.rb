require "rails_helper"

describe "Service availability", :js do
  let(:user) { create(:user) }

  specify "available for single schools" do
    Current.user = user
    user_exists_in_dfe_sign_in(user:)
    user_is_signed_in(user:)

    visit energy_service_availability_path(id: "1010010")

    expect(page).to have_text("Service only available for single schools")
  end
end
