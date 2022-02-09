module Support
  class GroupOrTrustPresenter < BasePresenter
    # @return [String] Combines URN and name
    def uid_and_name
      "#{uid} - #{name}"
    end

    # @return [String]
    def formatted_address
      [address["street"], address["locality"], address["postcode"]]
        .reject(&:blank?)
        .to_sentence(last_word_connector: ", ")
    end

    def group_type
      return I18n.t("support.case_categorisations.label.none") if uid.blank?

      group_type_id = Support::EstablishmentGroup.find_by(uid: uid).establishment_group_type_id
      @group_type_name = Support::EstablishmentGroupType.where(id: group_type_id).first.name
    end
  end
end
