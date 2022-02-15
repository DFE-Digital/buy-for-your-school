module Support
  class EstablishmentGroupPresenter < ::Support::BasePresenter
    # @return [String] Combines URN and name
    def urn_and_name
      "#{urn} - #{name}"
    end

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

    def postcode
      address["postcode"]
    end

    def urn
      # :noop:
    end

    def establishment_type_name
      return unless establishment_group_type

      establishment_group_type.name
    end

    def gias_url
      "https://www.get-information-schools.service.gov.uk/Groups/Group/Details/#{uid}"
    end

    def gias_label
      I18n.t("support.case.link.view_group_information")
    end

    def group_type
      return I18n.t("support.case_categorisations.label.none") if uid.blank?

      group_type_id = Support::EstablishmentGroup.find_by(uid: uid).establishment_group_type_id
      @group_type_name = Support::EstablishmentGroupType.where(id: group_type_id).first.name
    end
  end
end
