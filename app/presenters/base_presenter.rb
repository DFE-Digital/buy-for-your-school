class BasePresenter < SimpleDelegator
  # @return [String]
  def created_at
    super.strftime(date_format)
  end

  # @return [String]
  def updated_at
    super.strftime(date_format)
  end

private

  # @return [String] 30 March 2000
  def date_format
    "%e %B %Y"
  end
end
