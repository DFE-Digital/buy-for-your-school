# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"

module Energy
  module Documents
    class PortalAccessForm
      include Energy::Documents::XlSheetHelper

      STARTING_ROW_NUMBER = 1
      WORKSHEET_INDEX = 0

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
        @worksheet ||= workbook.worksheets[WORKSHEET_INDEX]
      end

      def establishment_group
        @establishment_group ||= Support::EstablishmentGroup.find_by(uid: @organisation.trust_code)
      end

      def postcode
        @organisation.address["postcode"]
      end

      def email_addresses
        @current_user.email
      end

      def vat_rate_yes_no
        @onboarding_case_organisation.vat_rate == 5 ? "Y" : "N"
      end

      def direct_debit_yes_no
        @onboarding_case_organisation.billing_payment_method_direct_debit? ? "Y" : "N"
      end

      def access_type
        @onboarding_case_organisation.billing_invoicing_method_email? ? "Email Push" : "Email Pull"
      end
    end
  end
end
