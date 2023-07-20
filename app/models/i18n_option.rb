class I18nOption
  def self.from(i18ntpath, collection)
    collection.map { |key| new(i18ntpath, key) }
  end

  attr_reader :title, :id

  def initialize(i18ntpath, id)
    @title = I18n.t(i18ntpath.gsub("%%key%%", id.downcase))
    @id = id
  end
end
