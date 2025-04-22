require "rails_helper"

RSpec.describe Energy::CreateTotalEnergiesVatCertificatePdf, type: :model do
  let(:input_values) do
    {
      business_name: "Test Business",
      vat_registration_no: "123456789",
      address_line1: "123 Main St",
      address_line2: "Suite 4",
      city: "Test City",
      postcode: "12345",
      commodity: "Electricity",
      percentage_of_property_rated: "75%",
      full_name_and_status_of_signatory: "John Doe, Director",
      signed: "Yes",
      date: "2025-04-21",
    }
  end
  let(:pdf_generator) { described_class.new(input_values) }

  describe "#initialize" do
    it "initializes with input values" do
      expect(pdf_generator.input_values).to eq(input_values)
    end
  end

  describe "#generate" do
    context "when the template file exists" do
      before do
        pdf_generator.generate
      end

      it "creates new pdf file" do
        expect(File.exist?(pdf_generator.output_pdf_file)).to be true
      end

      it "matches the input values with the output pdf" do
        fields = pdf_generator.pdftk.get_fields(pdf_generator.output_pdf_file)
        values = fields.map(&:value).compact
        expect(values).to eq(input_values.values)
      end
    end

    context "when the template file does not exist" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "raises an error" do
        expect { pdf_generator.generate }.to raise_error("Missing template file")
      end
    end
  end

  describe "#input_pdf_template_path" do
    it "returns the correct template path" do
      expect(pdf_generator.input_pdf_template_file).to eq(
        Energy::CreateTotalEnergiesVatCertificatePdf::INPUT_PDF_TEMPLATE_PATH.join("totalenergies_vat_declaration_certificate_mb.pdf"),
      )
    end
  end

  describe "#output_pdf_file" do
    it "returns the correct output pdf path" do
      expect(pdf_generator.output_pdf_file).to eq(Energy::CreateTotalEnergiesVatCertificatePdf::OUTPUT_PDF_PATH.join("filled_totalenergies_vat_declare_certificate_#{Time.current.to_i}.pdf"))
    end
  end

  describe "#form_field_values" do
    it "transforms the input values correctly" do
      expected_values = {
        Text3: "Test Business",
        Text4: "123456789",
        Text5: "123 Main St",
        Text6: "Suite 4",
        Text7: "Test City",
        Text8: "12345",
        Text9: "Electricity",
        Text10: "75%",
        Text11: "John Doe, Director",
        Text12: "Yes",
        Text13: "2025-04-21",
      }
      expect(pdf_generator.send(:form_field_values)).to eq(expected_values)
    end
  end
end
