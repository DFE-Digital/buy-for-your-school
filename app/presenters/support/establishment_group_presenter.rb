module Support
  class EstablishmentGroupPresenter < ::Support::BasePresenter
    # @return [String] Combines URN and name
    def urn_and_name
      "#{urn} - #{name}"
    end

    # @return [String]
    def formatted_address
      [address["street"], address["locality"], address["postcode"]]
        .reject(&:blank?)
        .to_sentence(last_word_connector: ", ")
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
  end
end
