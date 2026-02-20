module HasRelatedContent
  extend ActiveSupport::Concern

  included do
    attr_reader :related_content
  end

  def initialize(entry)
    @related_content = entry.fields.fetch(:related_content, []).map { |content| RelatedContent.new(content) }
  end
end
