SimpleXlsxReader.configuration.catch_cell_load_errors = true

# This monkey patch is required to prevent an unhandled error within SimpleXlsxReader
# If there is a hyperlink reference to something that doesn't exist it blows up.
# vendor/bundle/ruby/3.2.0/gems/simple_xlsx_reader-5.0.0/lib/simple_xlsx_reader/loader/sheet_parser.rb:217
# NOTE: lines below may differ from gem due to rubocop

class SimpleXlsxReader::Loader::SheetParser::HyperlinksParser
  def start_element(name, attrs)
    case name
    when "hyperlink"
      attrs = attrs.each_with_object({}) do |(k, v), acc|
        acc[k] = v
      end
      id = attrs["id"] || attrs["r:id"]

      @hyperlinks_by_cell[attrs["ref"]] =
        @xrels.at_xpath(%(//*[@Id="#{id}"])).attr("Target")
    end
  rescue NoMethodError
    # ignore hyperlink errors present in the spreadsheet
  end
end
