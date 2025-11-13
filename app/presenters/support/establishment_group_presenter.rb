module Support
  class EstablishmentGroupPresenter < ::Support::BasePresenter
    include Concerns::AddressFormatting
    # @return [String] Combines URN and name
    # :nocov:
    def urn_and_name
      "#{urn} - #{name}"
    end

    # @return [String] Combines URN and name
    def uid_and_name
      "#{uid} - #{name}"
    end
    # :nocov:

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

      group_type_id = Support::EstablishmentGroup.find_by(uid:).establishment_group_type_id
      @group_type_name = Support::EstablishmentGroupType.where(id: group_type_id).first.name
    end

    def ukprn
      super.presence || I18n.t("generic.not_provided")
    end

    def eligible_for_school_picker?
      (mat_or_trust? || federation?) && organisations.count > 1
    end
  end
end
