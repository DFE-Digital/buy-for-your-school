require "rails_helper"

describe "Guidance page", :js do
  specify "Guidance page contents" do
    visit energy_guidance_path

    expect(page).to have_text("All state-funded schools and trusts in England can join Energy for Schools.")
    expect(page).to have_text("Individual schools, like local authority-maintained schools and single academy trusts, can join using the online service.")
    expect(page).to have_link("Register your interest form", href: "https://submit.forms.service.gov.uk/form/8895/multi-academy-trusts-register-your-interest-in-energy-for-schools/1049539")
    expect(page).to have_text("Smart meter installation")
  end

  context "when allow_mat_flow feature flag is OFF" do
    before do
      Flipper.disable(:allow_mat_flow)
    end

    specify "Guidance page contents for single school flow" do
      visit energy_guidance_path

      expect(page).to have_text("Multi-academy trusts (MATs) can join by filling in Register your interest form and completing the process offline. A member of the DfE team will then contact you and help you complete the process offline.")
    end
  end

  context "when allow_mat_flow feature flag is ON" do
    before do
      Flipper.enable(:allow_mat_flow)
    end

    specify "Guidance page contents for multi school flow" do
      visit energy_guidance_path

      expect(page).to have_text("Multi-academy trusts (MATs) can join by repeating the online process for each school that's switching to the energy contract.")
      expect(page).to have_text("Alternatively, MATs can fill in the Register your interest form and complete the paperwork offline. This may benefit MATs that are ready to switch 6 or more schools to the energy deal.")
    end
  end
end
