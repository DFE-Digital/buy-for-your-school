require "rails_helper"

RSpec.describe Energy::Documents::GasPriceChangeForecast do
  let(:single_meter_school) { JSON.parse(Rails.root.join("spec/fixtures/gas_school_single_meter.json").read).dig("contacts", 0, "schools", 0) }
  let(:multi_meter_school) { JSON.parse(Rails.root.join("spec/fixtures/gas_school_multi_meter.json").read).dig("contacts", 0, "schools", 0) }
  let(:nine_meter_school) { JSON.parse(Rails.root.join("spec/fixtures/gas_school_nine_meters.json").read).dig("contacts", 0, "schools", 0) }

  describe "#call" do
    it "renders a single-meter gas forecast as an A4 landscape PDF" do
      rendered_html = "<html>forecast</html>"
      pdf_data = "%PDF-1.4 test"
      allow(ApplicationController).to receive(:render).and_return(rendered_html)
      wicked_pdf = instance_double(WickedPdf, pdf_from_string: pdf_data)
      allow(WickedPdf).to receive(:new).and_return(wicked_pdf)

      path = described_class.new(school: single_meter_school).call

      expect(ApplicationController).to have_received(:render).with(
        hash_including(
          template: "energy/gas_price_updates/single_meter_pdf",
          layout: "energy/gas_price_updates/pdf",
        ),
      )
      expect(wicked_pdf).to have_received(:pdf_from_string).with(
        rendered_html,
        encoding: "UTF-8",
        page_size: "A4",
        orientation: "Landscape",
      )
      expect(File.binread(path)).to eq(pdf_data)
    ensure
      File.delete(path) if path && File.exist?(path)
    end

    it "rejects schools with more than nine meters" do
      school = multi_meter_school
      school["meters"] *= 5

      expect { described_class.new(school:) }.to raise_error(ArgumentError, "A school must have between 1 and 9 gas meters")
    end

    it "renders a multi-meter breakdown and forecast as an A4 portrait PDF" do
      rendered_html = "<html>multi-meter forecast</html>"
      pdf_data = "%PDF-1.4 test"
      allow(ApplicationController).to receive(:render).and_return(rendered_html)
      wicked_pdf = instance_double(WickedPdf, pdf_from_string: pdf_data)
      allow(WickedPdf).to receive(:new).and_return(wicked_pdf)

      path = described_class.new(school: multi_meter_school, month: "October").call

      expect(ApplicationController).to have_received(:render).with(
        hash_including(
          template: "energy/gas_price_updates/multi_meter_pdf",
          layout: "energy/gas_price_updates/pdf",
          assigns: hash_including(month: "October", single_meter: false),
        ),
      )
      expect(wicked_pdf).to have_received(:pdf_from_string).with(
        rendered_html,
        encoding: "UTF-8",
        page_size: "A4",
        orientation: "Portrait",
      )
      expect(File.binread(path)).to eq(pdf_data)
    ensure
      File.delete(path) if path && File.exist?(path)
    end

    it "renders all nine meter columns in the A4 portrait PDF" do
      rendered_html = "<html>nine-meter forecast</html>"
      pdf_data = "%PDF-1.4 test"
      allow(ApplicationController).to receive(:render).and_return(rendered_html)
      wicked_pdf = instance_double(WickedPdf, pdf_from_string: pdf_data)
      allow(WickedPdf).to receive(:new).and_return(wicked_pdf)

      path = described_class.new(school: nine_meter_school, month: "October").call

      expect(nine_meter_school.fetch("meters").size).to eq(9)
      expect(ApplicationController).to have_received(:render).with(
        hash_including(assigns: hash_including(meters: nine_meter_school.fetch("meters"))),
      )
      expect(wicked_pdf).to have_received(:pdf_from_string).with(
        rendered_html,
        encoding: "UTF-8",
        page_size: "A4",
        orientation: "Portrait",
      )
      expect(File.binread(path)).to eq(pdf_data)
    ensure
      File.delete(path) if path && File.exist?(path)
    end
  end
end
