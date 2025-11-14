module Support
  class OrganisationPresenter < BasePresenter
    include Concerns::AddressFormatting
    # @return [String] Combines URN and name
    def urn_and_name
      "#{urn} - #{name}"
    end

    def postcode
      address["postcode"]
    end

    # @return [String]
    def local_authority
      return I18n.t("generic.not_provided") unless super

      super.name
    end

    # @return [String]
    def contact
      return I18n.t("generic.not_provided") unless super

      "#{super['title']} #{super['first_name']} #{super['last_name']}"
    end

    # @return [String, nil]
    def phase
      return I18n.t("generic.not_provided") unless super

      super.to_s.humanize
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

    def ukprn
      super.presence || I18n.t("generic.not_provided")
    end

    def eligible_for_school_picker?
      false
    end
  end
end
