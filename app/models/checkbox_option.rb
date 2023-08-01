class CheckboxOption
  attr_reader :id, :title, :exclusive

  def self.from(collection, id_field: :id, title_field: :title, include_all: false, include_unspecified: false)
    result = collection.map { |key| new(id: key.send(id_field), title: key.send(title_field)) }
    result.unshift(unspecified) if include_unspecified
    result.unshift(all) if include_all
    result
  end

  def self.all
    new(id: "all", title: "All", exclusive: true)
  end

  def self.unspecified
    new(id: "unspecified", title: "Unspecified", exclusive: true)
  end

  def initialize(id:, title:, exclusive: false)
    @id = id
    @title = title
    @exclusive = exclusive
  end
end
