require "timeout"

module AutocompleteHelpers
  def select_autocomplete_option(option, wait: 10)
    Timeout.timeout(wait, nil, "unable to find an autocomplete option with text #{option}") { sleep 1 until find(".autocomplete__option", text: option) }
    find(".autocomplete__option", text: option).click
  end
end
