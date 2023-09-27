module Support
  module Concerns
    module HasOrganisation
      extend ActiveSupport::Concern

      included do
      end

      def organisation_name
        return unless organisation

        decorated_organisation.name
      end

      def organisation_postcode
        return unless organisation

        decorated_organisation.postcode
      end

      def organisation_urn
        return unless organisation

        decorated_organisation.urn
      end

      def organisation_ukprn
        return unless organisation

        decorated_organisation.ukprn
      end

      def organisation_type_name
        return unless organisation

        decorated_organisation.establishment_type_name || ""
      end

      def organisation_gias_url
        return unless organisation

        decorated_organisation.gias_url || ""
      end

      def organisation_gias_label
        return unless organisation

        decorated_organisation.gias_label
      end

      def organisation
        return super if __getobj__.respond_to?(:organisation) && super.present?

        @organisation ||= Support::EstablishmentSearch.find_record(organisation_id, organisation_type)
      end

      def decorated_organisation
        return if organisation.blank?

        "#{organisation_type}Presenter".safe_constantize.new(organisation)
      end

      def eligible_for_school_picker?
        return false unless organisation

        decorated_organisation.eligible_for_school_picker?
      end
    end
  end
end
