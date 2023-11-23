module Frameworks::Framework::SpreadsheetImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_spreadsheet(file)
      frameworks_list = SimpleXlsxReader.open(file).sheets
        .find { |potential_sheet| potential_sheet.name == "Recommended Framework List" }

      frameworks_list.rows.each(headers: true) do |row|
        row_mapping = RowMapping.new(row)
        import_from_spreadsheet_row(row_mapping) if row_mapping.valid?
      end
    end

    def import_from_spreadsheet_row(row_mapping)
      framework = find_or_initialize_by(provider: row_mapping.provider, provider_reference: row_mapping.provider_reference)
      framework.source = :spreadsheet_import
      framework.attributes = row_mapping.attributes
      framework.save!
    end
  end
end
