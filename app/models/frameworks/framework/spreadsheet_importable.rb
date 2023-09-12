module Frameworks::Framework::SpreadsheetImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_spreadsheet(file)
      frameworks_list = SimpleXlsxReader.open(file)
        .sheets
        .find { |potential_sheet| potential_sheet.name == "Recommended Framework List" }

      populated_rows = frameworks_list.rows
        .each(headers: true)
        .reject { |row| row[nil].nil? }

      populated_rows
        .each { |row| import_from_spreadsheet_row(RowMapping.new(row)) }
    end

    def import_from_spreadsheet_row(row_mapping)
      framework = find_or_initialize_by(provider: row_mapping.provider, reference: row_mapping.reference)
      framework.source = :spreadsheet_import
      framework.attributes = row_mapping.attributes
      framework.save!
    end
  end
end
