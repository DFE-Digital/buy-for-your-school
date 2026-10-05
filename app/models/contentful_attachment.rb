class ContentfulAttachment
  attr_reader :title, :description

  def initialize(asset)
    @asset = asset
    @title = asset.title
    @description = asset.description
  end

  def url
    # "//assets.ctfassets.net/o6csh136j1jr/5XpQHpoMekRGAgQoeLw6EO/c7df13854c7dc6116237f4fee5f367d7/test.pdf"
    url = @asset.url
    url.start_with?("//") ? "https:#{url}" : url
  end

  def file_name
    @asset.file&.file_name
  end

  def file_size
    details = @asset.file&.details || {}
    details["size"] || details[:size]
  end

  def file_type
    File.extname(file_name.to_s).delete(".").upcase.presence
  end

  def link_text
    title.presence || file_name || "Download file"
  end
end
