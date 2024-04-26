class ChangeStateForGroupOfCases < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      kase_refs = %w[003112
                     003142
                     003451
                     002026
                     002824
                     002889
                     002893
                     002908
                     002909
                     002914
                     002919
                     002921
                     002934
                     002935
                     002942
                     002947
                     002955
                     002969
                     002977
                     002989
                     003001
                     003005
                     003006
                     003014
                     003015
                     003019
                     003026
                     003028
                     003040
                     003042
                     003045
                     003050
                     003057
                     003065
                     003066
                     003068
                     003070
                     003072
                     003074
                     003106
                     003107
                     003113
                     003119
                     003135
                     003141
                     003143
                     003182
                     003223
                     002875
                     002951
                     002979
                     002980
                     002986
                     002924
                     002435
                     002469
                     002475
                     002528
                     002326]
      kase_refs.each do |ref|
        kase = Support::Case.find_by(ref:)
        next if kase.blank? || kase.resolved?

        kase.update!(state: :resolved, action_required: false)
        Support::Interaction.state_change.create!(
          body: "From closed to resolved by support team on #{Time.zone.now.to_formatted_s(:short)}",
          case_id: kase.id,
        )
        Support::RecordAction.new(case_id: kase.id, action: "change_state", data: { old_state: :closed, new_state: :resolved }).call
      end
    end
  end

  def down; end
end
