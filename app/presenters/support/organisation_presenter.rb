module Support
  class OrganisationPresenter < BasePresenter
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

    def postcode
      address["postcode"]
    end

    # @return [String, nil]
    def local_authority
      super["name"] if super
    end

    # @return [String]
    def contact
      "#{super['title']} #{super['first_name']} #{super['last_name']}" if super
    end

    # @return [String, nil]
    def phase
      super.to_s.humanize if super
    end

    def establishment_type_name
      return unless establishment_type

      establishment_type.name
    end

    def gias_url
      "https://www.get-information-schools.service.gov.uk/Establishments/Establishment/Details/#{urn}"
    end

    def gias_label
      I18n.t("support.case.link.view_school_information")
    end
  end
end
