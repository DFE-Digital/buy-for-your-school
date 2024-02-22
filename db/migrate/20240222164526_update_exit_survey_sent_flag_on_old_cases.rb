class UpdateExitSurveySentFlagOnOldCases < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      kase_refs = %w[000042 000077 000252]
      kase_refs.each do |ref|
        kase = Support::Case.find_by(ref:)
        kase.update!(exit_survey_sent: true) if kase.present?
      end
    end
  end

  def down; end
end
