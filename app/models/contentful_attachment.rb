class ContentfulAttachment
  attr_reader :page_count

  def initialize(entry)
    @page_count = entry.fields[:page_count].to_s[/\d+/]&.to_i
    @asset = entry.fields[:attachment]
  end

  def url
    url = @asset&.url
    return if url.blank?

    url.start_with?("//") ? "https:#{url}" : url
  end

  def description
    @asset&.description
  end

  def title
    @asset&.title
  end

  def file_name
    @asset&.file&.file_name
  end

  def file_size
    details = @asset&.file&.details || {}
    details["size"] || details[:size]
  end

  def file_type
    File.extname(file_name.to_s).delete(".").upcase.presence
  end

  def thumbnail
    case file_type
    when "PDF" then "pdf"
    when "DOC", "DOCX", "ODT", "RTF", "TXT" then "document"
    when "XLS", "XLSX", "ODS", "CSV" then "spreadsheet"
    else "generic"
    end
  end

  def link_text
    title.presence || file_name || "Download file"
  end
end
