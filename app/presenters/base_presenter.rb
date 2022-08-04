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

  # @return [String] 26 November 2021
  def date_format
    I18n.t("date.formats.presenter")
  end

  # @return [String] html from markdown
  def format(content)
    DocumentFormatter.new(
      content:,
      from: :markdown,
      to: :html,
    ).call
  end
end
