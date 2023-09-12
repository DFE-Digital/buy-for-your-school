class Frameworks::ActivityLoggableVersion::PresentableChanges::FieldChange
  attr_reader :version, :item, :previous_item, :field, :changes

  def initialize(version, field, changes)
    @version = version
    @field = field
    @changes = changes
    @item = version.item
    @previous_item = version.previous.try(:item)
  end

  def field_name
    field.humanize
  end

  def display
    "#{value_or_empty(from)} <span class=\"activity-log-change-arrow\">➔</span> #{value_or_empty(to)}".html_safe
  end

private

  def to
    item.activity_log_display(field) || changes.last
  end

  def from
    previous_item.try(:activity_log_display, field) || changes.first
  end

  def value_or_empty(value)
    value.nil? ? "empty" : value
  end
end
