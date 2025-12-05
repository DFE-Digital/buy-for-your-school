require "rails_helper"

describe "Guidance page", :js do
  specify "Guidance page contents" do
    visit energy_guidance_path

    expect(page).to have_text("All state-funded schools and trusts in England can join Energy for Schools.")
    expect(page).to have_text("Individual schools, like local authority-maintained schools and single academy trusts, can join using the online service.")
    expect(page).to have_link("Register your interest form", href: "https://submit.forms.service.gov.uk/form/8895/multi-academy-trusts-register-your-interest-in-energy-for-schools/1049539")
  end
end
