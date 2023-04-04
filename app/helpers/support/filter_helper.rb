module Support
  module FilterHelper
    def toggle_visibility?(key, form)
      params[key].present? && form.filters_selected? ? "govuk-!-display-block" : "govuk-!-display-none"
    end
  end
end
