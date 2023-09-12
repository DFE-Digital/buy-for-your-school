class Frameworks::ActivityLoggableVersion::PresentableChanges
  PresentableChange = Struct.new(:field, :from, :to, keyword_init: true)

  include Enumerable

  def initialize(version)
    @version = version
  end

  def each
    return to_enum(:each) unless block_given?

    @version.object_changes.except("id", "created_at", "updated_at").each do |field, changes|
      from = @version.display_field_version(field:, value: changes.first)
      to = @version.display_field_version(field:, value: changes.last)

      yield PresentableChange.new(field:, from:, to:)
    end
  end
end
