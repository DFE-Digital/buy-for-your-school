class GetExpertHelp
  include ActiveModel::Model

  attr_reader :id, :title, :description

  def initialize(entry)
    @id = entry.id
    @title = entry.fields[:title]
    @description = entry.fields[:description]
  end
end
