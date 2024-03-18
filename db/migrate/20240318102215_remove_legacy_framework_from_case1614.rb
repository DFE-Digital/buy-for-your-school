class RemoveLegacyFrameworkFromCase1614 < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      kase = Support::Case.find_by(ref: "001614")
      kase.procurement.update!(framework: nil) if kase.present? && kase.procurement.present?
    end
  end

  def down; end
end
