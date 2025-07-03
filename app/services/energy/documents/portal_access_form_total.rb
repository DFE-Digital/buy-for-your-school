# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"

module Energy
  module Documents
    class PortalAccessFormTotal
      include Energy::Documents::XlSheetHelper
      TEMPLATE_FILE = "Portal Access Template Total.xlsx"
      STARTING_ROW_NUMBER = 1

      def initialize(onboarding_case:)
        @onboarding_case = onboarding_case
        @support_case = onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
      end

      def call
        build_portal_access_data
      end

      def input_template_file_xl
        @input_template_file_xl ||= INPUT_XL_TEMPLATE_PATH.join(TEMPLATE_FILE)
      end

      def output_file_xl
        @output_file_xl ||= OUTPUT_XL_PATH.join("Total portal Access_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def workbook
        @workbook ||= RubyXL::Parser.parse(input_template_file_xl)
      end

      def worksheet
        @worksheet ||= workbook.worksheets[1]
      end

      def build_portal_access_data
        {
          "Key" => "Value",
        }
      end
    end
  end
end
