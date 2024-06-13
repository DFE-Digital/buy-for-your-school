class MoveEmailsToCase3533 < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      outlook_conversation_id = "AAQkADA0NTlmYmU2LTI2ZGMtNDVjYi1iNDEyLTdhMGNmMGM2OWEyZAAQAAE1pFpGL6xKpxxI5DlVhFM="
      target_case = Support::Case.find_by(ref: "003533")
      return if target_case.nil?

      emails = Email.where(outlook_conversation_id:)
      return if emails.empty?

      emails.each do |email|
        next if email.ticket_id == target_case.id

        email.update!(ticket_id: target_case.id)
      end
    end
  end

  def down; end
end
