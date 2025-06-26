# frozen_string_literal: true

require "rubyXL"
require "rubyXL/convenience_methods/cell"

module Energy
  module Documents
    class SiteAdditionFormTotal
      include Energy::Documents::XlSheetHelper
      TEMPLATE_FILE = "Site Addition Form Total.xlsx"
      STARTING_ROW_NUMBER = 10

      def initialize(onboarding_case:)
        @onboarding_case = onboarding_case
        @support_case = onboarding_case.support_case
        @organisation = @support_case.organisation
        @onboarding_case_organisation = onboarding_case.onboarding_case_organisations.first
      end

      def call
        raise "Missing template file: #{input_template_file_xl}" unless File.exist?(input_template_file_xl)

        gas_meters.each_with_index do |gas_meter, row_index|
          site_addition_data = build_site_addition_data(gas_meter)

          site_addition_data.each_with_index do |(_key, value), column_index|
            cell = worksheet[STARTING_ROW_NUMBER + row_index][column_index]
            next if cell.nil?

            cell.change_contents(value)
          end
        end
        workbook.write(output_file_xl)
      end

      def input_template_file_xl
        @input_template_file_xl ||= INPUT_XL_TEMPLATE_PATH.join(TEMPLATE_FILE)
      end

      def output_file_xl
        # @output_file_xl ||= OUTPUT_XL_PATH.join("TOTAL Site Addition_#{@support_case.ref}_#{Date.current}.xlsx")
        @output_file_xl ||= OUTPUT_XL_PATH.join("total_xl_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def workbook
        @workbook ||= RubyXL::Parser.parse(input_template_file_xl)
      end

      def worksheet
        @worksheet ||= workbook.worksheets[0]
      end

      def gas_meters
        @gas_meters ||= Energy::GasMeter.includes(:onboarding_case_organisation).where(energy_onboarding_case_organisation_id: @onboarding_case_organisation.id)
      end

      def build_site_addition_data(gas_meter)
        organisation_details.merge(main_contact_details)
                            .merge(site_and_billing_addresses)
                            .merge(gas_meter_details(gas_meter))
      end

      def set_value
        "N/A"
      end

      def organisation_details
        {
          "*Group Name" => "Department for Education",
          "*Central Organisation Address Line 1" => "Sanctuary Bulidings",
          "*Central Organisation Address Line 2" => "Great Smith Street",
          "*Central Organisation Address Line 3" => "London",
          "*Central Organisation Address Line 4" => "",
          "*Central Organisation Postcode" => "SW1P 3BT",
        }
      end

      def main_contact_details
        {
          "Contact Title" => "Mrs",
          "*Contact First Name" => "Annette",
          "*Contact Surname" => "Harrison",
          "*Contact Address Line 1" => "Department for Education",
          "*Contact Address Line 2" => "2 St Paul's Place",
          "Contact Address Line 3" => "125 Norfolk Street",
          "Contact Address Line 4" => "Sheffield",
          "*Contact Postcode" => "S1 2JF",
          "*Contact phone" => "07530050691",
          "Contact Fax" => "n/a",
          "*Contact Email" => "annette.harrison@education.gov.uk",
        }
      end

      def site_and_billing_addresses
        {
          "Site Code" => "",
          "*Site Name" => @organisation.name,
          "Site Area" => "",
          "Site Manager" => "",
          "*Site Type" => "School",
          "*Site Contact First Name" => @onboarding_case_organisation.site_contact_first_name,
          "*Site Contact Surname" => @onboarding_case_organisation.site_contact_last_name,
          "*Site Contact phone" => @onboarding_case_organisation.site_contact_phone,
          "*Site Contact Email" => @onboarding_case_organisation.site_contact_email,
          "Site Customer Own Ref" => "",
          "*Billing Address Line 1" => billing_address_line1,
          "*Billing Address Line 2" => site_address_line2,
          "*Billing Address Town/City" => billing_address_city,
          "*Billing Address Country" => "UK",
          "*Billing Address Postcode" => billing_address_postcode,
          "Special Instructions" => "Department for Education/#{@organisation.name}",
          "*Site Address Line 1" => site_address_line1,
          "*Site Address Line 2" => site_address_line2,
          "*Country" => "UK",
          "*Post Code" => site_address_postcode,
          "*Town/City" => site_address_city,
        }
      end

      def gas_meter_details(gas_meter)
        {
          "*Incumbent Supplier" => gas_supplier,
          "*Incumbent Contract End Date" => contract_end_date.strftime("%d/%m/%Y"),
          "*Incumbent Supplier Notice Given?" => "No",
          "*Currently Out Of Contract?" => "No",
          "MPRN" => gas_meter.mprn,
          "*Start Date" => supply_start_date,
          "*AQ (kWh) - Annual Quota" => gas_meter.gas_usage,
          "*Payment Type" => payment_method,
          "*Payment Terms" => @onboarding_case_organisation.billing_payment_terms.to_s[/\d+/],
          "*VAT Rate (%)" => @onboarding_case_organisation.vat_rate,
          "*Is this a single meter or multi meter site?" => gas_meter_type,
          "Premise level aggregation required - Please detail MPRs to aggregate" => "",
          "*Billing Method" => billing_invoicing_method,
          "*Email address(es) for online bills" => @onboarding_case_organisation.billing_invoicing_email,
          "*Billing Notification Preference" => "Check with BA",
        }
      end

      def site_address
        @site_address ||= (@organisation.address || {}).with_indifferent_access
      end

      def site_address_line1
        site_address[:street]
      end

      def site_address_line2
        site_address[:locality]
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
        @billing_address ||= @onboarding_case_organisation.billing_invoice_address.to_h.with_indifferent_access
      end

      def billing_address_line1
        billing_address[:street]
      end

      def billing_address_line2
        billing_address[:locality]
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

      def gas_supplier
        supplier = @onboarding_case_organisation.gas_current_supplier || @onboarding_case_organisation.gas_current_supplier_other
        if supplier == "edf_energy"
          "EDF Energy"
        elsif supplier == "eon_next"
          "E.ON Next"
        else
          supplier.titleize
        end
      end

      def contract_end_date
        @contract_end_date ||= @onboarding_case_organisation.gas_current_contract_end_date
      end

      def supply_start_date
        (contract_end_date + 1.day).strftime("%d/%m/%Y")
      end

      def payment_method
        return if @onboarding_case_organisation.billing_payment_method_gov_procurement_card?

        @onboarding_case_organisation.billing_payment_method_bacs? ? "Bacs" : "Direct Debit"
      end

      def billing_invoicing_method
        @onboarding_case_organisation.billing_invoicing_method_email? ? "E-Billing" : "Paper"
      end

      def gas_meter_type
        @onboarding_case_organisation.gas_single_multi_single? ? "Single meter site" : "Multi meter site"
      end
    end
  end
end
