class Version::PresentableChanges
  PresentableChange = Struct.new(:field, :from, :to, keyword_init: true)

  include Enumerable

  def initialize(version)
    @version = version
  end

  def each
    return to_enum(:each) unless block_given?

    @version.field_changes.each do |field, changes|
      from = @version.display_field_version(field:, value: changes.first)
      to = @version.display_field_version(field:, value: changes.last)

      # Ignore empty -> empty changes
      next if [String(to), String(from)].all?(&:empty?)

      yield PresentableChange.new(field:, from:, to:)
    end
  end
end
