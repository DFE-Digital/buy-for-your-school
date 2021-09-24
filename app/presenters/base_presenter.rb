class BasePresenter < SimpleDelegator
  # @return [String]
  def created_at
    format_date(super)
  end

  # @return [String]
  def updated_at
    format_date(super)
  end

private

  # @return [String]
  def format_date(date)
    date.strftime("%e %B %Y")
  end
end
