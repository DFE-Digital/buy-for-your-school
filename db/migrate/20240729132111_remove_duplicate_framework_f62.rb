class RemoveDuplicateFrameworkF62 < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      framework = Frameworks::Framework.where(reference: "F62").first
      if framework.present?
        framework.destroy!
      end
    end
  end

  def down; end
end
