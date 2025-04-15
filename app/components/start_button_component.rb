# frozen_string_literal: true

class StartButtonComponent < ViewComponent::Base
  def initialize(url:, text: I18n.t("generic.button.start"))
    @text = text
    @url = url
  end
end
