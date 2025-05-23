require "rails_helper"

RSpec.describe Energy::CreateEdfPowerSiteAdditionsXl, type: :model do
  let(:input_values) do
    {
      customer_name: "New High School",
      site_address_line_1: "77 High Street",
      site_address_line_2: "",
      site_address_city: "Watford",
      site_address_post_code: "WD25 0UU",
      billing_address_line_1: "77 High Street",
      billing_address_line_2: "",
      billing_address_city: "Watford",
      billing_address_postcode: "WD25 0UU",
      current_contract_end_date: "31/10/2025",
      supply_start_date_with_edf: "01/11/2025",
      mpan: "S0380112345671234567",
      hh_nhh: "nHH",
      supply_capacity_kva_hh_meters_only: "",
      estimated_annual_consumption_eac: "12500",
      data_aggregator: "Data Aggregator",
      data_collector: "Data Collector",
      meter_operator: "Meter Operator",
      payment_method: "Direct Debit",
      payment_durration: "10",
      energy_source: "Standard",
      consolidated_billing_yes_no: "No",
      key_business_contact_full_name: "Department Education",
      key_business_contact_email: "dfe@test.gov.uk",
      company_registered_address_line_1: "20 Great Smith Street",
      company_registered_address_line_2: "",
      customer_registered_city: "London",
      company_registered_postcode: "SW1P 3BT",
      company_registration_charity_number: "1234512345",
    }
  end
  let(:xl_generator) { described_class.new(input_values) }
  let(:starting_row) { Energy::CreateEdfPowerSiteAdditionsXl::STARTING_ROW_NUMBER }

  describe "#initialize" do
    it "initializes with input values" do
      expect(xl_generator.input_values).to eq(input_values)
    end
  end

  describe "#generate" do
    context "when the template file exists" do
      before do
        xl_generator.generate
      end

      it "creates new xl file" do
        expect(File.exist?(xl_generator.output_xl_file)).to be true
      end

      it "matches the input values with the output xl" do
        workbook = RubyXL::Parser.parse(xl_generator.output_xl_file)
        worksheet = workbook.worksheets[1]

        expect(worksheet[starting_row][0].value).to eq(input_values[:customer_name])
        expect(worksheet[starting_row][11].value).to eq(input_values[:mpan])
        expect(worksheet[starting_row][23].value).to eq(input_values[:key_business_contact_email])
      end
    end

    context "when the template file does not exist" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "raises an error" do
        expect { xl_generator.generate }.to raise_error("Missing template file")
      end
    end
  end

  describe "#input_xl_template_path" do
    it "returns the correct template path" do
      expect(xl_generator.input_xl_template_file).to eq(
        Energy::CreateEdfPowerSiteAdditionsXl::INPUT_XL_TEMPLATE_PATH.join("power_site_additions_template.xlsx"),
      )
    end
  end

  describe "#output_xl_file" do
    it "returns the correct output xl path" do
      expect(xl_generator.output_xl_file).to eq(Energy::CreateEdfPowerSiteAdditionsXl::OUTPUT_XL_PATH.join("filled_power_site_additions_#{Time.current.to_i}.xlsx"))
    end
  end

  describe "#cell_input_values" do
    it "assigns the input values correctly" do
      expect(xl_generator.send(:cell_input_values)).to eq(input_values)
    end
  end
end
