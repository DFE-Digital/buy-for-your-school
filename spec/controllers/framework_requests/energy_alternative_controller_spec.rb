require "./spec/support/shared/framework_request_controllers"

describe FrameworkRequests::EnergyAlternativeController, type: :controller do
  include_examples "back url", "/procurement-support/energy_bill"

  context "when the user has selected different format" do
    include_examples "sign-in redirects", { framework_support_form: { energy_alternative: "different_format" } }
  end

  context "when the user has selected email later" do
    include_examples "sign-in redirects", { framework_support_form: { energy_alternative: "email_later" } }
  end

  context "when the user has selected no bill" do
    include_examples "sign-in redirects", { framework_support_form: { energy_alternative: "no_bill" } }
  end

  context "when the user has selected no thanks" do
    include_examples "sign-in redirects", { framework_support_form: { energy_alternative: "no_thanks" } }
  end
end
