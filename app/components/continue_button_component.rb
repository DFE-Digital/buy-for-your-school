# frozen_string_literal: true

class ContinueButtonComponent < ViewComponent::Base
  def initialize(url:, text: I18n.t("generic.button.continue"))
    @url = url
    @text = text
  end
end
