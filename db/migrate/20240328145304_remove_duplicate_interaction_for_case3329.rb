class RemoveDuplicateInteractionForCase3329 < ActiveRecord::Migration[7.1]
  def up
    if ENV["APPLICATION_URL"] == "https://www.get-help-buying-for-schools.service.gov.uk"
      kase = Support::Case.find_by(ref: "003329")
      if kase.present?
        interaction = kase.interactions.find_by(id: "ab9e4079-d74b-4c9b-a831-02af906aa4a1")
        interaction.destroy! if interaction.present?
      end
    end
  end

  def down; end
end
