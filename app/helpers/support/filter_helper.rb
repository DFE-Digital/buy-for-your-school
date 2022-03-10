module Support
  module FilterHelper
    def toggle_visibility?(key)
      params[key].present? ? "govuk-!-display-block" : "govuk-!-display-none"
    end
  end
end
