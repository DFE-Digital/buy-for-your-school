class Support::Concerns::ScopeFilter
  def initialize(value, scope:, mapping: {}, multiple: true)
    @values = Array(value).map { |v| mapping[v] || v }.flatten
    @scope = scope
    @mapping = mapping
    @multiple = multiple
  end

  def filter(records)
    return records if selected_all? || !entered?
    return records.send("#{scope}_unspecified") if selected_unspecified?

    records.send(scope, multiple ? values : values.first)
  end

  def selected?(*checked_for_values)
    values.inquiry.any?(*checked_for_values)
  end

  def selected_all?
    selected?(:all)
  end

  def selected_unspecified?
    selected?(:unspecified)
  end

  def entered?
    values.any? { |value| value.present? || value == false }
  end

private

  attr_reader :scope, :values, :mapping, :multiple
end
