# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"

module Energy
  module Documents
    class SiteAdditionForm
      include Energy::Documents::XlSheetHelper
      CUSTOMER_NAME = "Department for Education"
      CUSTOMER_ADDRESS_LINE1 = "Sanctuary Buildings"
      CUSTOMER_ADDRESS_LINE2 = "Great Smith Street"
      CUSTOMER_ADDRESS_CITY = "London"
      CUSTOMER_ADDRESS_POSTCODE = "SW1P 3BT"

      def initialize(onboarding_case:, current_user:)
        @onboarding_case = onboarding_case
        @support_case = onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
        @current_user = current_user
      end

      def input_template_file_xl
        @input_template_file_xl ||= INPUT_XL_TEMPLATE_PATH.join(self.class::TEMPLATE_FILE)
      end

      def workbook
        @workbook ||= RubyXL::Parser.parse(input_template_file_xl)
      end

      def worksheet
        @worksheet ||= workbook.worksheets[self.class::WORKSHEET_INDEX]
      end

      def establishment_group
        @establishment_group ||= Support::EstablishmentGroup.find_by(uid: @organisation.trust_code)
      end

      def site_address
        @site_address ||= (@organisation.address || {}).with_indifferent_access
      end

      def site_address_line1
        @organisation.name
      end

      def site_address_line2
        [site_address[:street], site_address[:locality]].reject(&:blank?).join(", ").strip
      end

      def site_address_line3
        site_address[:county]
      end

      def site_address_city
        site_address[:town]
      end

      def site_address_postcode
        site_address[:postcode]
      end

      def billing_address
        @billing_address ||= @onboarding_case_organisation.billing_invoice_address.to_h.with_indifferent_access.presence || site_address
      end

      def billing_address_line1
        mat_address? ? establishment_group&.name : @organisation.name
      end

      def billing_address_line2
        [billing_address[:street], billing_address[:locality]].reject(&:blank?).join(", ").strip
      end

      def billing_address_line3
        billing_address[:county]
      end

      def billing_address_city
        billing_address[:town]
      end

      def billing_address_postcode
        billing_address[:postcode]
      end

      def mat_address?
        Support::EstablishmentGroup.find_by(id: @onboarding_case_organisation.billing_invoice_address_source_id).present?
      end
    end
  end
end
