class ChangeStateForCase40 < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      kase = Support::Case.find_by(ref: "000040")
      kase.update!(state: :resolved) if kase.present?
    end
  end

  def down; end
end
