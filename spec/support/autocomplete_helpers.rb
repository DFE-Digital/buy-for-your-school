module AutocompleteHelpers
  def select_autocomplete_option(option, wait: 2)
    find(".autocomplete__option", text: option, wait: wait).click
  end
end
