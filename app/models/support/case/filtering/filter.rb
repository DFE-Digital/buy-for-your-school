class Support::Case::Filtering::Filter
  def initialize(value, scope:, multiple: true)
    @values = Array(value)
    @scope = scope
    @multiple = multiple
  end

  def filter(cases)
    return cases if selected_all? || !entered?
    return cases.send("#{scope}_unspecified") if selected_unspecified?

    cases.send(scope, multiple ? values : values.first)
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

  attr_reader :scope, :values, :multiple
end
