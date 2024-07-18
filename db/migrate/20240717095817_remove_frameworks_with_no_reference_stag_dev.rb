class RemoveFrameworksWithNoReferenceStagDev < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] != "https://www.get-help-buying-for-schools.service.gov.uk"

      no_reference_frameworks = Frameworks::Framework.where(reference: "")
      no_reference_frameworks.each(&:destroy!)
    end
  end

  def down; end
end
