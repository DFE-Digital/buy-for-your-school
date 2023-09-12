RSpec::Matchers.define :have_summary do |label, text|
  match do |page|
    page.find(".govuk-summary-list__value", text:)&.sibling(".govuk-summary-list__key", text: label).present?
  rescue Capybara::ElementNotFound
    false
  end

  match_when_negated do |page|
    page.find(".govuk-summary-list__value", text:)&.sibling(".govuk-summary-list__key", text: label).blank?
  rescue Capybara::ElementNotFound
    true
  end

  failure_message do |page|
    available_keys = page.all(".govuk-summary-list__key").map do |key|
      "#{key.text} => #{key.sibling('.govuk-summary-list__value').try(:text) || '-empty-'}"
    end

    <<~MESSAGE
      expected to find summary row with label "#{label}" and text "#{text}" but did not.

      Found summary keys:
      #{available_keys.join("\n")}
    MESSAGE
  end

  failure_message_when_negated do |page|
    available_keys = page.all(".govuk-summary-list__key").map do |key|
      "#{key.text} => #{key.sibling('.govuk-summary-list__value').try(:text) || '-empty-'}"
    end

    <<~MESSAGE
      expected not to find summary row with label "#{label}" and text "#{text}" but it did appear.

      Found summary keys:
      #{available_keys.join("\n")}
    MESSAGE
  end
end
