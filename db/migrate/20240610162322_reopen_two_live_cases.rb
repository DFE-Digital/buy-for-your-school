class ReopenTwoLiveCases < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      kase_refs = %w[003533 002850]
      kase_refs.each do |ref|
        kase = Support::Case.find_by(ref:)
        next if kase.blank? || kase.opened?

        kase.update!(state: :opened, action_required: false)
        Support::Interaction.state_change.create!(
          body: "From closed to open by support team on #{Time.zone.now.to_formatted_s(:short)} as per a request by Asad Mayat",
          case_id: kase.id,
        )
        Support::RecordAction.new(case_id: kase.id, action: "change_state", data: { old_state: :closed, new_state: :opened }).call
      end
    end
  end

  def down; end
end
