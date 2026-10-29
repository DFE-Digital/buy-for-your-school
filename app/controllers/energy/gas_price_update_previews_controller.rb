# frozen_string_literal: true

module Energy
  class GasPriceUpdatePreviewsController < ::ApplicationController
    skip_before_action :authenticate_user!

    def index; end

    def single_meter
      preview("gas_school_single_meter.json")
    end

    def multi_meter
      preview("gas_school_multi_meter.json")
    end

    def nine_meters
      preview("gas_school_nine_meters.json")
    end

  private

    def preview(fixture_name)
      pricing_data = JSON.parse(Rails.root.join("spec/fixtures", fixture_name).read)
      school = pricing_data.dig("contacts", 0, "schools", 0)
      pdf_path = Energy::Documents::GasPriceChangeForecast.new(school:).call
      pdf_data = File.binread(pdf_path)

      send_data pdf_data,
                type: "application/pdf",
                disposition: "inline",
                filename: File.basename(pdf_path)
    ensure
      File.delete(pdf_path) if pdf_path && File.exist?(pdf_path)
    end
  end
end
