class ContentfulRecordNotFoundError < StandardError
  attr_reader :slug

  def initialize(message = nil, slug: nil, id: nil)
    super(message)
    @slug = slug
    @id = id
  end
end
