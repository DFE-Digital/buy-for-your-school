class CookiePreferencesForm
  extend Dry::Initializer
  option :accepted_or_rejected

  def options
    [
      OpenStruct.new(value: 'accepted', label: I18n.t("cookies.information.analytics_cookies.action.choice_yes")),
      OpenStruct.new(value: 'rejected', label: I18n.t("cookies.information.analytics_cookies.action.choice_no"))
    ]
  end
end
