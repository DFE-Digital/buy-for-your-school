module Energy
  module Documents
    module PortalAccessXlHelper
      STARTING_ROW_NUMBER = 1
      WORKSHEET_INDEX = 0

      def workbook
        @workbook ||= RubyXL::Parser.parse(input_template_file_xl)
      end

      def worksheet
        @worksheet ||= workbook.worksheets[WORKSHEET_INDEX]
      end
    end
  end
end
