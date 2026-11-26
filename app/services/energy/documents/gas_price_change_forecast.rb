require "base64"
require "wicked_pdf"

module Energy
  module Documents
    class GasPriceChangeForecast
      MONTHS = %w[April May June July August September October November December January February March].freeze

      def initialize(school:, month: Date.current.strftime("%B"))
        @school = school
        meters = school.fetch("meters")
        raise ArgumentError, "A school must have between 1 and 9 gas meters" unless meters.count.between?(1, 9)
        raise ArgumentError, "Unknown gas price update month: #{month}" unless MONTHS.include?(month)

        @meters = meters
        @month = month
        @single_meter = meters.one?
      end

      def call
        File.binwrite(file_path, generate_pdf)
        file_path
      end

    private

      def generate_pdf
        WickedPdf.new.pdf_from_string(render_html, encoding: "UTF-8", page_size: "A4", orientation:)
      end

      def render_html
        ApplicationController.render(
          template:,
          layout:,
          assigns: {
            school: @school,
            meters: @meters,
            meter: @meters.first,
            forecast_months: MONTHS,
            month: @month,
            single_meter: @single_meter,
            logo_data_uri:,
          },
        )
      end

      def logo_data_uri
        encoded_logo = Base64.strict_encode64(File.binread(Rails.root.join("app/assets/images/department-for-education_black.png")))
        "data:image/png;base64,#{encoded_logo}"
      end

      def file_path
        Rails.root.join("tmp", "Gas price change forecast_#{@school.fetch('School URN')}_#{Date.current}.pdf")
      end

      def orientation
        @single_meter ? "Landscape" : "Portrait"
      end

      def template
        @single_meter ? "energy/gas_price_updates/single_meter_pdf" : "energy/gas_price_updates/multi_meter_pdf"
      end

      def layout
        "energy/gas_price_updates/pdf"
      end
    end
  end
end
