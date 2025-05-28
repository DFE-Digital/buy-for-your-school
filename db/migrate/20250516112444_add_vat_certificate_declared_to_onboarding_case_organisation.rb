class AddVatCertificateDeclaredToOnboardingCaseOrganisation < ActiveRecord::Migration[7.2]
  def change
    add_column :energy_onboarding_case_organisations, :vat_certificate_declared, :boolean, default: false
  end
end
