# frozen_string_literal: true

module Energy
  module Documents
    class SiteAdditionFormTotal < SiteAdditionForm
      TEMPLATE_FILE = "Site Addition Form Total.xlsx"
      STARTING_ROW_NUMBER = 10
      WORKSHEET_INDEX = 0

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

      def output_file_xl
        @output_file_xl ||= OUTPUT_XL_PATH.join("TOTAL Site Addition_#{@support_case.ref}_#{Date.current}.xlsx")
      end

    private

      def gas_meters
        @gas_meters ||= Energy::GasMeter.includes(:onboarding_case_organisation).where(energy_onboarding_case_organisation_id: @onboarding_case_organisation.id)
      end

      def build_site_addition_data(gas_meter)
        organisation_details.merge(main_contact_details)
                            .merge(site_and_billing_addresses)
                            .merge(gas_meter_details(gas_meter))
      end

      def organisation_details
        {
          "*Group Name" => CUSTOMER_NAME,
          "*Central Organisation Address Line 1" => CUSTOMER_ADDRESS_LINE1,
          "*Central Organisation Address Line 2" => CUSTOMER_ADDRESS_LINE2,
          "*Central Organisation Address Line 3" => CUSTOMER_ADDRESS_CITY,
          "*Central Organisation Address Line 4" => "",
          "*Central Organisation Postcode" => CUSTOMER_ADDRESS_POSTCODE,
        }
      end

      def main_contact_details
        {
          "Contact Title" => "Mrs",
          "*Contact First Name" => "Annette",
          "*Contact Surname" => "Harrison",
          "*Contact Address Line 1" => CUSTOMER_NAME,
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
          "*Billing Address Line 2" => billing_address_line2,
          "*Billing Address Town/City" => billing_address_city,
          "*Billing Address Country" => "UK",
          "*Billing Address Postcode" => billing_address_postcode,
          "Special Instructions" => special_instructions,
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
          "*Incumbent Contract End Date" => gas_contract_end_date.strftime("%d/%m/%Y"),
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
          "*Email address(es) for online bills" => email_for_online_bills,
          "*Billing Notification Preference" => billing_notification_preference,
        }
      end

      def special_instructions
        [CUSTOMER_NAME, @establishment_group&.name, @organisation.name].compact.join("/")
      end

      def gas_supplier
        supplier = @onboarding_case_organisation.gas_current_supplier || @onboarding_case_organisation.gas_current_supplier_other

        case supplier
        when "other"
          @onboarding_case_organisation.gas_current_supplier_other
        when "edf_energy"
          "EDF Energy"
        when "eon_next"
          "E.ON Next"
        else
          supplier.titleize
        end
      end

      def gas_contract_end_date
        @gas_contract_end_date ||= @onboarding_case_organisation.gas_current_contract_end_date
      end

      def supply_start_date
        (gas_contract_end_date + 1.day).strftime("%d/%m/%Y")
      end

      def payment_method
        @onboarding_case_organisation.billing_payment_method_bacs? ? "Bacs" : "Direct Debit"
      end

      def billing_invoicing_method
        @onboarding_case_organisation.billing_invoicing_method_email? ? "E-Billing" : "Paper"
      end

      def gas_meter_type
        @onboarding_case_organisation.gas_single_multi_single? ? "Single meter site" : "Multi meter site"
      end

      def email_for_online_bills
        @onboarding_case_organisation.billing_invoicing_method_paper? ? @current_user.email : @onboarding_case_organisation.billing_invoicing_email
      end

      def billing_notification_preference
        @onboarding_case_organisation.billing_invoicing_method_email? ? "Email with invoice attachment" : "Email invoice notification with link to TGP Portal"
      end
    end
  end
end
