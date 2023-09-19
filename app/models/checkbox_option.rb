class CheckboxOption
  attr_reader :id, :title, :exclusive

  def self.from(collection, id_field: :id, title_field: :title, include_all: false, include_unspecified: false, exclusive_fields: [])
    result = collection.map do |key|
      id = key.respond_to?(id_field) ? key.send(id_field) : key[id_field]
      title = key.respond_to?(title_field) ? key.send(title_field) : key[title_field]
      exclusive = exclusive_fields.include?(id)
      new(id:, title:, exclusive:)
    end
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
