module Support
  module FilterHelper
    def toggle_visibility?(key, form)
      params[key].present? && form.user_submitted? ? "govuk-!-display-block" : "govuk-!-display-none"
    end
  end
end
